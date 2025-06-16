{ config, pkgs, lib }:
{
  services.uptime-kuma.enable = true;
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "kuma";
          uri = "http://localhost:4000";
        }
      ];
    };
  };
}
