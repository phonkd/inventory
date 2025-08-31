{ lib, config, pkgs, ... }:
{
  services.alloy.enable = true;
  # systemd.services.alloy.serviceConfig = {
  #     # Alloy normally runs as an unprivileged user; force root instead.
  #   User  = lib.mkForce "root";
  #   Group = lib.mkForce "root";  # optional, but usually pair with User
  # };
  services.prometheus.exporters.node = {
    enabledCollectors = ["node"];
    enable = true;
  };
  environment.etc."alloy/config.alloy" = {
    text = ''
      prometheus.scrape "nixvms" {
        targets    = http://localhost:9100
        forward_to = [prometheus.remote_write.nixvms.receiver]
      }
      prometheus.remote_write "nixvms" {
        endpoint {
          url = "http://192.168.1.121:9090/api/v1/write"
        }
      }
      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }

      loki.source.journal "read"  {
        forward_to    = [loki.write.endpoint.receiver]
        relabel_rules = loki.relabel.journal.rules
        labels        = {component = "loki.source.journal"}
      }

      loki.write "endpoint" {
        endpoint {
          url ="http://192.168.1.121:9428/insert/loki/api/v1/push"
        }
      }
    '';
  };

}
