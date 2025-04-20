{ config, pkgs, ... }:
{
  services.zipline = {
    enable = true;
  };
  services.caddy = {
    virtualHosts."clipz.nix-services.phonkd.net".extraConfig = ''
      reverse_proxy :3000
    '';
  };
}
