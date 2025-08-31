# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  sops.secrets."pve.yml" = {
    sopsFile = pve.yml;
  };
  environment.etc."grafana-dashboards/pve.json".source = ./pve.json;
  environment.etc."pve.yml".source = ./pve.yml
  services.prometheus = {
    exporters.node = {
      enabledCollectors = ["pve"];
    };
    # # scrapeConfigs = [
    #   {
    #     job_name = "pve";
    #     static_configs = [
    #       {
    #         targets = [
    #           "http://localhost:9222"
    #         ];
    #       }
    #     ];
    #   }
    # ];
    exporters.pve = {
      configFile = "/etc/prometheus/pve.yml";
    };
  };
}
