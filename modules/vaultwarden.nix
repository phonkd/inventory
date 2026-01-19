{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vw.w.phonkd.net/";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8000;
      #SIGNUPS_ALLOWED = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 8000 ];
  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden-https = {
      rule = "Host(`vw.w.phonkd.net`)";
      entryPoints = [ "websecure" ];
      service = "vaultwarden";
      tls = {
        certResolver = "cloudflare";
        domains = [
          {
            main = "vw.w.phonkd.net";
          }
        ];
      };
    };
    services.vaultwarden = {
      loadBalancer = {
        servers = [
          { url = "http://127.0.0.1:8000"; }
        ];
      };
    };
  };
}
