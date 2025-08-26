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
      // --- Write destination: VictoriaLogs (Loki-compatible push) ---
      loki.write "victorialogs" {
        endpoint {
          // Change host:port to wherever VictoriaLogs is reachable
          url = "http://192.168.1.121:9428/insert/loki/api/v1/push"
        }
      }

      // --- (Optional) Relabel a few useful journald fields into normal Loki labels ---
      loki.relabel "journal_labels" {
        // Map journald unit name to {unit=...}
        rule {
          source_labels = ["__journal__systemd_unit"]  // from journald field _SYSTEMD_UNIT
          target_label  = "unit"
        }
        // Map host name to {host=...}
        rule {
          source_labels = ["__journal__hostname"]      // from journald field _HOSTNAME
          target_label  = "host"
        }
      }

      // --- Read the local systemd journal ---
      loki.source.journal "systemd" {
        // Where to send entries next
        forward_to    = [loki.process.system.receiver]

        // Keep the useful labels from above
        relabel_rules = loki.relabel.journal_labels.rules
        labels = {
          app = "systemd"
        }

        // Optional tuning:
        // path       = "/var/log/journal"  // autodetects /var/log/journal and /run/log/journal by default
        // max_age    = "24h"               // only read the last 24h on start
        // matches    = "_SYSTEMD_UNIT=ssh.service" // journal match (AND-ed only)
      }
      loki.process "system" {
        // Example: drop very noisy units (uncomment & edit to taste)
        stage.drop {
          source = "unit"
          expression = "^(systemd-resolved.service|systemd-timesyncd.service)$"
        }
        stage.labels {
          values = {
            source = "journal"
          }
        }

        forward_to = [loki.write.victorialogs.receiver]
      }
    '';
  };

}
