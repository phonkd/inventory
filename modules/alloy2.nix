{ config, pkgs, ... }:
{
  services.alloy.enable = true;
  environment.etc."alloy/config.alloy" = {
    text = ''
      prometheus.exporter.unix "nixvms" { }
      prometheus.scrape "nixvms" {
        targets    = prometheus.exporter.unix.nixvms.targets
        forward_to = [prometheus.remote_write.nixvms.receiver]
      }
      prometheus.remote_write "nixvms" {
        endpoint {
          url = "http://192.168.1.121:9090/api/v1/write"
        }
      }
      loki.write "victorialogs" {
        endpoint {
          url = "http://192.168.1.121:9428/insert/loki/api/v1/push"
        }
      }
      loki.relabel "journal" {
        forward_to = []
        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }
      loki.source.journal "systemd" {
        forward_to    = []
        relabel_rules = loki.relabel.journal.rules
        labels = {component = "loki.source.journal"}
      }
      loki.process "drop" {
        stage.drop {
          source = "unit"
          expression = "^(systemd-resolved.service|systemd-timesyncd.service)$"
        }
        forward_to = [loki.write.victorialogs.receiver]
      }
    '';
  };

}
