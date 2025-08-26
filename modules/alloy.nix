{ config, pkgs, ... }:
{
  services.alloy.enable = true;
  environment.etc."alloy/config.alloy" = {
    text = ''
      prometheus.exporter.unix "nixvms" { }

      // Configure a prometheus.scrape component to collect unix metrics.
      prometheus.scrape "nixvms" {
        targets    = prometheus.exporter.unix.nixvms.targets
        forward_to = [prometheus.remote_write.nixvms.receiver]
      }

      prometheus.remote_write "nixvms" {
        endpoint {
          url = "https://192.168.1.121:/api/v1/write"
        }
      }
    '';
  };
}
