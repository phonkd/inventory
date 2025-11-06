{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.alloy.enable = true;
  # systemd.services.alloy.serviceConfig = {
  #     # Alloy normally runs as an unprivileged user; force root instead.
  #   User  = lib.mkForce "root";
  #   Group = lib.mkForce "root";  # optional, but usually pair with User
  # };
  services.prometheus.exporters.node = {
    # enabledCollectors = [
    #   "node"
    #   "postgres"
    # ];
    enable = true;
  };

  environment.etc."alloy/config.alloy" = {
    text =
      let
        hostname = config.networking.hostName;
      in
      ''
        prometheus.exporter.unix "gagu" { }

        // Configure a prometheus.scrape component to collect unix metrics.
        prometheus.scrape "gagu" {
          targets    = prometheus.exporter.unix.gagu.targets
          forward_to = [prometheus.remote_write.nixvms.receiver]
        }

        prometheus.remote_write "nixvms" {
          external_labels = {
            hostname = "${hostname}",
            instance = "${hostname}",
          }
          endpoint {
            url = "http://192.168.1.121:9090/api/v1/write"
            remote_timeout = "10s"
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
          labels        = {
            component = "loki.source.journal",
          }
        }

        loki.write "endpoint" {
          external_labels = {
            hostname = "${hostname}",
          }
          endpoint {
            url ="http://192.168.1.121:9428/insert/loki/api/v1/push"
          }
        }
      '';
  };
}
