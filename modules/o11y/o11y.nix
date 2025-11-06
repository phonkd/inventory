# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "grafana";
          uri = "http://localhost:3000";
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
    package = pkgs.unstable.grafana;
    openFirewall = true;
    settings = {
      server.http_addr = "0.0.0.0";
      feature_toggles = {
        enable = "provisioning kubernetesDashboards";
      };
    };
    # declarativePlugins = with pkgs.unstable.grafanaPlugins; [
    #     victoriametrics-logs-datasource
    #     grafana-metricsdrilldown-app
    #     grafana-lokiexplore-app
    #     grafana-exploretraces-app
    #     grafana-pyroscope-app
    # ];
    provision = {
      enable = true;
      dashboards.settings.providers = [
        {
          name = "dashboards";
          options = {
            path = "/etc/grafana-dashboards";
            foldersFromFilesStructure = true;
          };
        }
      ];
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
  #environment.etc."grafana-dashboards/mystrom.json".source = ./mystrom.json;
  # services.mimir = {
  #   enable = true;
  #   extraFlags = ["--compactor.blocks-retention-period 14d"];
  # };
  services.prometheus = {
    enable = true;
    retentionTime = "10y";
    extraFlags = [ "--web.enable-remote-write-receiver" ];
  };
  services.victorialogs.enable = true;
  networking.firewall.allowedTCPPorts = [
    9090
    9428
  ];
}
