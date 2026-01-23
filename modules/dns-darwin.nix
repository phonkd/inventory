{ config, pkgs, lib, ... }:

{
  services.dnsmasq = {
    enable = true;
    bind = "127.0.0.1";

    # Upstream DNS servers (Cloudflare)
    servers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    # Local domain resolution
    addresses = {
      ".int.phonkd.net" = "192.168.1.201";
      ".w.int.phonkd.net" = "192.168.1.201";
      ".segglaecloud.phonkd.net" = "192.168.1.123";
      ".w.phonkd.net" = "192.168.1.201";
    };
  };
}
