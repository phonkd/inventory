# Auto-generated using compose2nix v0.3.1.
{ pkgs, lib, ... }:

{
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
  virtualisation.oci-containers.containers."paperless-db" = {
    image = "postgres:16-alpine";
    environment = {
      "POSTGRES_DB" = "docmost";
      "POSTGRES_PASSWORD" = "STRONG_DB_PASSWORD";
      "POSTGRES_USER" = "docmost";
    };
    volumes = [
      "paperless_db_data:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=paperless_default"
    ];
  };
  systemd.services."podman-paperless-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_db_data.service"
    ];
    requires = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_db_data.service"
    ];
    partOf = [
      "podman-compose-paperless-root.target"
    ];
    wantedBy = [
      "podman-compose-paperless-root.target"
    ];
  };
  virtualisation.oci-containers.containers."paperless-docmost" = {
    image = "docmost/docmost:latest";
    environment = {
      "APP_SECRET" = "REPLACE_WITH_LONG_SECRET";
      "APP_URL" = "http://localhost:3000";
      "DATABASE_URL" = "postgresql://docmost:STRONG_DB_PASSWORD@db:5432/docmost?schema=public";
      "REDIS_URL" = "redis://redis:6379";
    };
    volumes = [
      "paperless_docmost:/app/data/storage:rw"
    ];
    ports = [
      "3000:3000/tcp"
    ];
    dependsOn = [
      "paperless-db"
      "paperless-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=docmost"
      "--network=paperless_default"
    ];
  };
  systemd.services."podman-paperless-docmost" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_docmost.service"
    ];
    requires = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_docmost.service"
    ];
    partOf = [
      "podman-compose-paperless-root.target"
    ];
    wantedBy = [
      "podman-compose-paperless-root.target"
    ];
  };
  virtualisation.oci-containers.containers."paperless-redis" = {
    image = "redis:7.2-alpine";
    volumes = [
      "paperless_redis_data:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=paperless_default"
    ];
  };
  systemd.services."podman-paperless-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_redis_data.service"
    ];
    requires = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_redis_data.service"
    ];
    partOf = [
      "podman-compose-paperless-root.target"
    ];
    wantedBy = [
      "podman-compose-paperless-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-paperless_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f paperless_default";
    };
    script = ''
      podman network inspect paperless_default || podman network create paperless_default
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-paperless_db_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect paperless_db_data || podman volume create paperless_db_data
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };
  systemd.services."podman-volume-paperless_docmost" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect paperless_docmost || podman volume create paperless_docmost
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };
  systemd.services."podman-volume-paperless_redis_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect paperless_redis_data || podman volume create paperless_redis_data
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-paperless-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
