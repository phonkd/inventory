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
}
