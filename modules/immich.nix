{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.immich.enable = true;
  services.immich.port = 2283;
  networking.firewall.allowedTCPPorts = [ 2283 ];
  networking.firewall.allowedUDPPorts = [ 2283 ];
  services.immich.host = "0.0.0.0";
  services.traefik.dynamicConfigOptions.http = {
    routers.immich-https = {
      rule = "Host(`immich.w.phonkd.net`)";
      tls.certResolver = "cloudflare";
      entryPoints = [ "websecure" ];
      service = "immich-service";
      middlewares = [
        "ip-filter"
      ];
    };
    services.immich-service = {
      loadBalancer = {
        servers = [
          { url = "http://192.168.1.121:2283"; }
        ];
      };
    };
  };
}
