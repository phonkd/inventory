# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.uptime-kuma.enable = false;
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "kuma";
          uri = "http://192.168.1.123:3001";
        }
      ];
    };
  };
}
