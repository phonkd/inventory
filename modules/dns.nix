# Auto-generated using compose2nix v0.3.
# 1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      # wildcard DNS
      address = [
        "/.int.phonkd.net/192.168.1.200"
        "/.int.phonkd.net/::"
        "/.segglaecloud.phonkd.net/192.168.1.123"
        "/.segglaecloud.phonkd.net/::"
        "/.w.phonkd.net/192.168.1.200"
        "/.w.phonkd.net/::"
      ];
      #filter-aaaa = true;
      # optional: refuse invalid domains (like domain-needed)
      domain-needed = true;

      # optional: ignore private reverse lookups (like bogus-priv)
      bogus-priv = true;
    };

  };
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  networking.networkmanager.dns = "none";

}
