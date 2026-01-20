{
  config,
  pkgs,
  lib,
  ...
}:
{
  phonkds.modules.vaultwarden.traefik = {
    ip = "127.0.0.1";
    port = 8000;
    domain = "vw.w.phonkd.net";
    auth = false;
    ipfilter = false;
  };
  # --------------------------------------- #
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://${config.phonkds.modules.vaultwarden.traefik.domain}";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8000;
      #SIGNUPS_ALLOWED = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 8000 ];
}
