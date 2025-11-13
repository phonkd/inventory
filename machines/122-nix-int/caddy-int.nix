{ config, pkgs, ... }:
{
  services.caddy = {
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-XwZ0Hkeh2FpQL/fInaSq+/3rCLmQRVvwBM0Y1G1FZNU=";
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
    # virtualHosts."segglaecloud.int.phonkd.net".extraConfig = ''
    #   reverse_proxy {
    #     to 192.168.1.123:80
    #     header_up X-Forwarded-Proto {scheme}
    #     header_up X-Forwarded-Host {host}
    #     header_up X-Forwarded-For {remote_host}
    #     header_down Server ""
    #   }
    # '';
  };
}
