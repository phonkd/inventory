{ config, pkgs, ... }:
{
services.caddy = {
  package = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
    hash = "sha256-Gsuo+ripJSgKSYOM9/yl6Kt/6BFCA6BuTDvPdteinAI=";
  };
  virtualHosts."*.nixk8s.phonkd.net".extraConfig = ''
    reverse_proxy {
      to 192.168.90.231:443
      transport http {
          tls
          tls_insecure_skip_verify
      }
    }
  '';
  virtualHosts."pve.int.phonkd.net".extraConfig = ''
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
