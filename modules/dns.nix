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
        "/.int.phonkd.net/192.168.1.201"
        "/.int.phonkd.net/::"
        "/.segglaecloud.phonkd.net/192.168.1.123"
        "/.segglaecloud.phonkd.net/::"
        "/.w.phonkd.net/192.168.1.201"
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
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "zyxel";
          uri = "https://192.168.1.1";
          insecure_skip_verify = true;
        }
        {
          name = "oldblac";
          uri = "https://192.168.1.47:8006";
          insecure_skip_verify = true;
        }
      ];
    };
  };
}
