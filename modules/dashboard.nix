{
  config,
  lib,
  ...
}:
let
  # Retrieve the central app configuration
  apps = config.phonkds.modules;

  # Filter apps that have Traefik enabled AND Dashboard enabled AND have a domain
  enabledApps = lib.filterAttrs (
    _: v: v.traefik.enable && v.dashboard.enable && v.traefik.domain != null
  ) apps;

  # Convert the filtered apps into the homepage-dashboard service format
  # Structure: [ { "AppName" = { icon = "..."; href = "..."; ... }; } ]
  serviceList = lib.mapAttrsToList (name: app: {
    "${name}" = {
      icon = if app.dashboard.icon != null then app.dashboard.icon else "${name}.png";
      href = if app.dashboard.link != null then app.dashboard.link else "https://${app.traefik.domain}";
      description = if app.traefik.domain != null then app.traefik.domain else "";
    };
  }) enabledApps;

  # Filter apps that have Teleport enabled AND Dashboard enabled
  teleportApps = lib.filterAttrs (_: v: v.teleport.enable && v.dashboard.enable) apps;

  # Convert teleport apps into the homepage-dashboard service format
  teleportServiceList = lib.mapAttrsToList (name: app: {
    "${name}" = {
      icon = if app.dashboard.icon != null then app.dashboard.icon else "${name}.png";
      href =
        if app.dashboard.link != null then
          app.dashboard.link
        else
          "https://${if app.teleport.name != null then app.teleport.name else name}.teleport.phonkd.net";
      description = "Teleport: ${if app.teleport.name != null then app.teleport.name else name}";
    };
  }) teleportApps;
in
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = false; # Expose the dashboard port (default 8082)
    settings = {
      background = {
        image = "https://public.s3.w.phonkd.net/walls/20251117_071020.jpg";
        blur = "sm";
        saturate = "30";
        brightness = "30";
        opacity = "80";
        maxGroupColumns = "2";
        fullWidth = "true";
      };
      cardblur = "md";
      headerStyle = "boxedWidgets";
    };
    widgets = [
      {
        resources = {
          label = "System";
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        resources = {
          label = "Shares";
          disk = "/mnt/Shares";
        };
      }
      {
        resources = {
          label = "S3";
          disk = "/mnt/s3";
        };
      }
      {
        resources = {
          label = "Syncthing";
          disk = "/mnt/syncthing";
        };
      }
    ];
    services = [
      {
        "Reverse proxied" = serviceList;
      }
      {
        "Teleported" = teleportServiceList;
      }
    ];
    allowedHosts = config.phonkds.modules.homepage.traefik.domain;
  };

  phonkds.modules.homepage = {
    ip = "127.0.0.1";
    port = 8082;
    dashboard.enable = true;
    traefik = {
      enable = true;
      domain = "dashboard.w.phonkd.net";
      ipfilter = false;
      auth = true;
    };
  };
}
