# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.pihole-ftl = {
    enable = true;
    openFirewallDHCP = true;
    openFirewallDNS = true;
    openFirewallWebserver = true;
    settings.webserver.port = "8001";
    settings.misc.readOnly = false;
  };
  services.pihole-web = {
    enable = true;
    ports = [ "8001" ];
  };
  #networking.firewall.allowedTCPPorts = [ 8001 ];
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "pihole";
          uri = "http://localhost:8001";
          insecure_skip_verify = true;
          rewrite = {
            headers = [
              "Host: pihole.teleport.phonkd.net"
            ];
          };
        }
      ];
    };
  };
  environment.etc."dnsmasq.d/99-wildcards.conf".text = ''
    address=/nix-services.phonkd.net/192.168.1.121
    address=/w.phonkd.net/192.168.1.121
    address=/segglaecloud.phonkd.net/192.168.1.123
  '';
}
