# Auto-generated using compose2nix v0.3.1.
{ pkgs, lib, config, ... }:
let
  flowtime_db_pw = if builtins.pathExists config.sops.secrets."flowtime_db_pw".path then
                    builtins.readFile config.sops.secrets."flowtime_db_pw".path
                  else
                    "default_auth_token_placeholder";
in
{
  sops.secrets.flowtime_db_pw = {};
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  # Enable container name DNS for non-default Podman networks.
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."hypnosis-app" = {
    image = "ghcr.io/phonkd/flowtime:1.1";
    environment = {
      "DATABASE_URL" = "postgresql://hypnosis:hypnosis_password@postgres:5432/hypnosis_db";
      "NODE_ENV" = "production";
      "POSTGRES_DB" = "hypnosis_db";
      "POSTGRES_HOST" = "postgres";
      "POSTGRES_PASSWORD" = "${flowtime_db_pw}";
      "POSTGRES_USER" = "hypnosis";
      "SESSION_SECRET" = "${flowtime_db_pw}";
      "USE_DATABASE" = "true";
    };
    volumes = [
      "flowtime_hypnosis_uploads:/app/uploads:rw"
    ];
    ports = [
      "5000:5000/tcp"
    ];
    dependsOn = [
      "hypnosis-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=app"
      "--network=flowtime_default"
    ];
  };
  systemd.services."podman-hypnosis-app" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-flowtime_default.service"
      "podman-volume-flowtime_hypnosis_uploads.service"
    ];
    requires = [
      "podman-network-flowtime_default.service"
      "podman-volume-flowtime_hypnosis_uploads.service"
    ];
    partOf = [
      "podman-compose-flowtime-root.target"
    ];
    wantedBy = [
      "podman-compose-flowtime-root.target"
    ];
  };
  virtualisation.oci-containers.containers."hypnosis-db" = {
    image = "postgres:14-alpine";
    environment = {
      "POSTGRES_DB" = "hypnosis_db";
      "POSTGRES_PASSWORD" = "${flowtime_db_pw}";
      "POSTGRES_USER" = "hypnosis";
    };
    volumes = [
      "flowtime_postgres_data:/var/lib/postgresql/data:rw"
    ];
    # ports = [
    #   "5432:5432/tcp"
    # ];
    cmd = [ "postgres" "-c" "max_connections=100" "-c" "shared_buffers=256MB" "-c" "effective_cache_size=1GB" "-c" "maintenance_work_mem=64MB" "-c" "checkpoint_completion_target=0.9" "-c" "wal_buffers=16MB" "-c" "default_statistics_target=100" "-c" "random_page_cost=1.1" "-c" "effective_io_concurrency=200" "-c" "work_mem=4MB" "-c" "min_wal_size=1GB" "-c" "max_wal_size=4GB" "-c" "listen_addresses=*" "-c" "log_connections=on" "-c" "log_disconnections=on" ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U hypnosis"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=postgres"
      "--network=flowtime_default"
    ];
  };
  systemd.services."podman-hypnosis-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-flowtime_default.service"
      "podman-volume-flowtime_postgres_data.service"
    ];
    requires = [
      "podman-network-flowtime_default.service"
      "podman-volume-flowtime_postgres_data.service"
    ];
    partOf = [
      "podman-compose-flowtime-root.target"
    ];
    wantedBy = [
      "podman-compose-flowtime-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-flowtime_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f flowtime_default";
    };
    script = ''
      podman network inspect flowtime_default || podman network create flowtime_default
    '';
    partOf = [ "podman-compose-flowtime-root.target" ];
    wantedBy = [ "podman-compose-flowtime-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-flowtime_hypnosis_uploads" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect flowtime_hypnosis_uploads || podman volume create flowtime_hypnosis_uploads
    '';
    partOf = [ "podman-compose-flowtime-root.target" ];
    wantedBy = [ "podman-compose-flowtime-root.target" ];
  };
  systemd.services."podman-volume-flowtime_postgres_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect flowtime_postgres_data || podman volume create flowtime_postgres_data
    '';
    partOf = [ "podman-compose-flowtime-root.target" ];
    wantedBy = [ "podman-compose-flowtime-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-flowtime-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
  services.caddy = {
    virtualHosts."flowtime.w.phonkd.net".extraConfig = ''
      reverse_proxy localhost:5000
    '';
  };
}
