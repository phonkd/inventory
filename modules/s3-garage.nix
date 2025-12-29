{
  config,
  pkgs,
  lib,
  ...
}:

{
  # 1. Create a static system user and group
  #    This ensures the user exists BEFORE the service starts, so sops can assign ownership.
  users.users.garage = {
    group = "garage";
    isSystemUser = true;
  };
  users.groups.garage = { };

  # 2. Configure SOPS
  #    We remove 'path', so sops stores secrets in /run/secrets/garage-* (RAM).
  #    We set 'owner' to 'garage' so the static user can read them.
  sops.secrets."garage-rpc" = {
    owner = "garage";
    mode = "0400";
  };

  sops.secrets."garage-metrics" = {
    owner = "garage";
    mode = "0400";
  };
  sops.secrets."garage-admin" = {
    owner = "garage";
    mode = "0400";
  };

  # 3. Configure Garage
  services.garage = {
    enable = true;
    package = pkgs.garage_2;

    settings = {
      replication_factor = 1;
      consistency_mode = "consistent";
      db_engine = "lmdb";

      # Standard data directories
      # Garage will be happy because sops is no longer messing with these folders.
      metadata_dir = "/mnt/s3/meta";
      data_dir = "/mnt/s3/data";

      rpc_bind_addr = "[::]:3901";
      bootstrap_peers = [ ];

      # POINT TO THE SOPS PATHS (in /run/secrets/)
      # config.sops.secrets.<name>.path automatically resolves to /run/secrets/<name>
      rpc_secret_file = config.sops.secrets."garage-rpc".path;

      s3_api = {
        api_bind_addr = "127.0.0.1:3900";
        s3_region = "us-east-1";
        root_domain = ".api.s3.w.phonkd.net";
      };

      admin = {
        api_bind_addr = "127.0.0.1:3903";
        metrics_token_file = config.sops.secrets."garage-metrics".path;
        admin_token_file = config.sops.secrets."garage-admin".path;
      };
      s3_web = {
        # 1. Bind to localhost (let your reverse proxy handle SSL/public access)
        bind_addr = "127.0.0.1:3902";

        # 2. Define the suffix for your websites
        #    If you create a bucket named "mysite", it will be served at:
        #    http://mysite.web.phonkd.net
        #    (You can also name a bucket "example.com" to serve that exact domain)
        root_domain = ".s3.w.phonkd.net";

        add_host_to_metrics = true;
      };
    };
  };

  # 4. OVERRIDE SYSTEMD SETTINGS
  #    We must explicitly disable DynamicUser.
  #    If we don't, Systemd will ignore our static 'garage' user and create a random one,
  #    which won't have permission to read the secrets.
  systemd.services.garage.serviceConfig = {
    DynamicUser = lib.mkForce false; # FORCE this off
    User = "garage";
    Group = "garage";
  };
  ## webui
  systemd.services.garage-webui = {
    description = "Garage Web UI";
    wantedBy = [ "multi-user.target" ];
    after = [ "garage.service" ];

    # We use 'script' to read the secret into a variable before the app starts
    script = ''
      # 1. Read the secret token from SOPS
      export API_ADMIN_KEY=$(cat ${config.sops.secrets."garage-admin".path})

      # 2. Configure the connection to Garage
      #    (The WebUI backend talks to these ports on localhost)
      export API_BASE_URL="http://127.0.0.1:3903"
      export S3_ENDPOINT_URL="http://localhost:3900"
      export S3_REGION="us-east-1"

      # 3. Start the WebUI
      exec ${pkgs.garage-webui}/bin/garage-webui
    '';

    serviceConfig = {
      User = "garage";
      Group = "garage";
      Restart = "always";
      RestartSec = "10s";

      # Optional: Clean up environment
      Environment = "PORT=3909";
    };
  };

  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "s3";
          uri = "http://localhost:3909";
          insecure_skip_verify = true;
        }
      ];
    };
  };
  fileSystems."/mnt/s3" = {
    device = "/dev/disk/by-id/virtio-vm-202-disk-2";
    fsType = "xfs";
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount

    ];
    autoFormat = true;
    autoResize = true;
  };
}
