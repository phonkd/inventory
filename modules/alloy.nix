{ config, pkgs, ... }:
{
  services.alloy.enable = true;
  environment.etc."alloy/config.alloy" = {
    text = ''
      prometheus.exporter.unix "demo" { }

      // Configure a prometheus.scrape component to collect unix metrics.
      prometheus.scrape "demo" {
        targets    = prometheus.exporter.unix.demo.targets
        forward_to = [prometheus.remote_write.demo.receiver]
      }

      prometheus.remote_write "demo" {
        endpoint {
          url = "https://prometheus.nixk8s.phonkd.net/api/v1/write"
        }
      }
    '';
  };


}
