{ config, pkgs, ... }:
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vw.w.phonkd.net/";
    };
  };
  services.caddy = {
    virtualHosts."vw.w.phonkd.net".extraConfig = ''
      reverse_proxy :8000
    '';
  };
}
