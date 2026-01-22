{
  config,
  lib,
  ...
}:
{
  phonkds.modules = {
    traefik = {
      ip = "127.0.0.1";
      port = 8080;
      path = "/dashboard/";
      dashboard = {
        enable = true;
        icon = "traefik";
      };
      teleport = {
        enable = true;
        insecure = true;
        name = "traefik";
        scheme = "http";
      };
    };
    easyeffects = {
      ip = "192.168.1.203";
      port = 8085;
      dashboard = {
        enable = true;
        icon = "https://public.s3.w.phonkd.net/icons/ezfx.svg";
      };
      traefik = {
        enable = true;
        auth = true;
        domain = "easyeffects.int.w.phonkd.net";
        ipfilter = true;
        extraMiddlewares = [ "vnc-root-rewrite" ];
        transport = "insecureTransport"; # Requires the update above
      };
    };
    oldblac = {
      dashboard = {
        enable = true;
        icon = "sh-proxmox";
      };
      teleport = {
        enable = true;
        name = "oldblac";
        scheme = "https";
        insecure = true;
        rewriteHeaders = [ "Host: oldblac.teleport.phonkd.net" ];
      };
      ip = "192.168.1.47";
      port = 8006;
      traefik = {
        enable = true;
        domain = "oldblac.int.phonkd.net";
        scheme = "https"; # Requires the update above
        transport = "insecureTransport"; # Requires the update above
        ipfilter = true;
        extraMiddlewares = [ "pve-headers" ];
      };
    };
    zyxel = {
      ip = "192.168.1.1";
      port = 443;
      dashboard = {
        enable = true;
        icon = "router";
      };
      teleport = {
        enable = true;
        name = "zyxel";
        scheme = "https";
        insecure = true;
      };
    };
  };
}
