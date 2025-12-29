{
  pkgs,
  lib,
  config,
  ...
}:

{
  # ============================================================================
  # 1. SOPS TEMPLATE (Auto-configure Filestash S3)
  # ============================================================================
  # This generates the config.json file securely so you don't need to use the Web UI setup wizard.
  sops.templates."filestash_config.json" = {
    owner = "root";
    content = ''
      {
        "system": {
          "host": "https://filestash.w.phonkd.net"
        },
        "backends": [
          {
            "type": "s3",
            "name": "My Garage S3",
            "endpoint": "s3.phonkd.net",
            "region": "us-east-1",
            "access_key": "${config.sops.placeholder.filestash_s3_key}",
            "secret_key": "${config.sops.placeholder.filestash_s3_secret}"
          }
        ]
      }
    '';
  };

  # ============================================================================
  # 2. RUNTIME & NETWORKING
  # ============================================================================
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.backend = "podman";

  # Enable DNS resolution for container names
  networking.firewall.interfaces =
    let
      matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
    in
    {
      "${matchAll}".allowedUDPPorts = [ 53 ];
    };

  # ============================================================================
  # 3. CONTAINERS
  # ============================================================================

  # --- Filestash Container ---
  virtualisation.oci-containers.containers."filestash" = {
    image = "machines/filestash:latest";
    environment = {
      "APPLICATION_URL" = "https://filestash.w.phonkd.net";
      "CANARY" = "true";
      # Internal networking URLs
      "OFFICE_FILESTASH_URL" = "http://app:8334";
      "OFFICE_URL" = "http://wopi_server:9980";
      # External Browser URL for Editor
      "OFFICE_REWRITE_URL" = "https://filestash.w.phonkd.net/collabora";
    };
    volumes = [
      "filestash_filestash:/app/data/state:rw"
      # Mount the generated config file over the default location
      "${config.sops.templates."filestash_config.json".path}:/app/data/state/config/config.json:ro"
    ];
    ports = [
      "8334:8334/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=app"
      "--network=filestash_default"
    ];
  };

  # --- Collabora / WOPI Container ---
  virtualisation.oci-containers.containers."filestash_wopi" = {
    image = "collabora/code:24.04.10.2.1";
    environment = {
      # Security: Only allow your domain to frame the editor
      "aliasgroup1" = "https://filestash.w.phonkd.net:443";
      "extra_params" = "--o:ssl.enable=false";
    };
    ports = [
      "9980:9980/tcp"
    ];
    # Custom command to load branding and start service
    cmd = [
      "/bin/bash"
      "-c"
      "curl -o /usr/share/coolwsd/browser/dist/branding-desktop.css https://gist.githubusercontent.com/mickael-kerjean/bc1f57cd312cf04731d30185cc4e7ba2/raw/d706dcdf23c21441e5af289d871b33defc2770ea/destop.css; /bin/su -s /bin/bash -c '/start-collabora-online.sh' cool"
    ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=wopi_server"
      "--network=filestash_default"
    ];
  };

  # ============================================================================
  # 4. SYSTEMD GLUE (Service Ordering & Resource Creation)
  # ============================================================================

  # --- Filestash Service Dependencies ---
  systemd.services."podman-filestash" = {
    serviceConfig.Restart = lib.mkOverride 90 "always";
    after = [
      "podman-network-filestash_default.service"
      "podman-volume-filestash_filestash.service"
    ];
    requires = [
      "podman-network-filestash_default.service"
      "podman-volume-filestash_filestash.service"
    ];
    partOf = [ "podman-compose-filestash-root.target" ];
    wantedBy = [ "podman-compose-filestash-root.target" ];
  };

  # --- WOPI Service Dependencies ---
  systemd.services."podman-filestash_wopi" = {
    serviceConfig.Restart = lib.mkOverride 90 "always";
    after = [ "podman-network-filestash_default.service" ];
    requires = [ "podman-network-filestash_default.service" ];
    partOf = [ "podman-compose-filestash-root.target" ];
    wantedBy = [ "podman-compose-filestash-root.target" ];
  };

  # --- Network Creation ---
  systemd.services."podman-network-filestash_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f filestash_default";
    };
    script = ''
      podman network inspect filestash_default || podman network create filestash_default
    '';
    partOf = [ "podman-compose-filestash-root.target" ];
    wantedBy = [ "podman-compose-filestash-root.target" ];
  };

  # --- Volume Creation ---
  systemd.services."podman-volume-filestash_filestash" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect filestash_filestash || podman volume create filestash_filestash
    '';
    partOf = [ "podman-compose-filestash-root.target" ];
    wantedBy = [ "podman-compose-filestash-root.target" ];
  };

  # --- Root Target ---
  systemd.targets."podman-compose-filestash-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
