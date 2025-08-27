# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "grafana";
          uri = "http://localhost:8686";
          insecure_skip_verify = true;
          rewrite = {
            headers = [
              "Host: grafana.teleport.phonkd.net"
            ];
          };
        }
      ];
    };
  };
  services.grafana = {
    enable = true;
    openFirewall = true;
    settings.server.http_addr = "0.0.0.0";
    declarativePlugins = with pkgs.grafanaPlugins; [
        victoriametrics-logs-datasource
    ];
    provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        }
        {
          name = "Victoriasigma";
          type = "victoriametrics-logs-datasource";
          url = "http://localhost:9428";
        }
      ];
    };
  };
  # services.mimir = {
  #   enable = true;
  #   extraFlags = ["--compactor.blocks-retention-period 14d"];
  # };
  services.prometheus = {
    enable = true;
    retentionTime = "14d";
    extraFlags = ["--web.enable-remote-write-receiver"];
  };
  services.victorialogs.enable = true;
  networking.firewall.allowedTCPPorts = [9090 9428];
}
