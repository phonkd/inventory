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
    openfirewallDNS = true;
  };
  services.pihole-web = {
    enable = true;
    ports = [ "8001s" ];
  };
}
