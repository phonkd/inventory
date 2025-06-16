# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.uptime-kuma.enable = true;
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "kuma";
          uri = "http://localhost:3001";
        }
      ];
    };
  };
}
