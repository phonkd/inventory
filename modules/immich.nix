{
  config,
  pkgs,
  lib,
  ...
}:
{
  # phonkds.modules.immich.traefik = {
  #   enable = true;
  #   ip = "127.0.0.1";
  #   port = 2283;
  #   domain = "immich.w.phonkd.net";
  #   ipfilter = true;
  # };
  services.immich.enable = true;
  services.immich.port = 2283;
  networking.firewall.allowedTCPPorts = [ 2283 ];
  networking.firewall.allowedUDPPorts = [ 2283 ];
  services.immich.host = "0.0.0.0";
}
