{ config, pkgs, lib, ... }:
{
  services.immich.enable = true;
  services.immich.port = 2283;
  networking.firewall.allowedTCPPorts = [2283];
  networking.firewall.allowedUDPPorts = [2283];
  #services.caddy = {
  #   virtualHosts."immich.w.phonkd.net".extraConfig = ''
  #     reverse_proxy localhost:2283
  #   '';
  # };
  #
}
