{ config, pkgs, ... }:
{
services.caddy = {
  virtualHosts."*.nixk8s.phonkd.net".extraConfig = ''
    reverse_proxy {
      to 192.168.90.231:443
      transport http {
          tls
          tls_insecure_skip_verify
      }
    }
  '';
  virtualHosts."pve.nix-services.phonkd.net".extraConfig = ''
    reverse_proxy {
      to 192.168.1.46:8006
      transport http {
          tls
          tls_insecure_skip_verify
      }
    }
  '';
  };
}
