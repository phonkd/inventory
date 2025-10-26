{ lib, config, pkgs, ... }:
{
  services.alloy.enable = true;
  # systemd.services.alloy.serviceConfig = {
  #     # Alloy normally runs as an unprivileged user; force root instead.
  #   User  = lib.mkForce "root";
  #   Group = lib.mkForce "root";  # optional, but usually pair with User
  # };
  services.prometheus.exporters.node = {
    enabledCollectors = ["arp" "bcache" "bonding" "buddyinfo" "conntrack" "cpu" "diskstats" "edac" "entropy" "filefd" "filesystem" "hwmon" "infiniband" "ipvs" "loadavg" "mdadm" "meminfo" "netclass" "netdev" "netstat" "nfs" "nfsd" "pressure" "rapl" "schedstat" "sockstat" "softnet" "stat" "textfile" "time" "timex" "uname" "vmstat" "xfs" "zfs"];
    enable = true;
  };
  environment.etc."alloy/config.alloy" = {
    text = ''
      livedebugging {
        enabled = true
      }
      prometheus.scrape "nixvms" {
        targets = [
          {
            "__address__" = "127.0.0.1:9100"
          }
        ]
        forward_to = [prometheus.remote_write.nixvms.receiver]
      }
      prometheus.remote_write "nixvms" {
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
