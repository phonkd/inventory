# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.syncthing.enable = true;
  #services.syncthing.guiAddress = "syncthing.teleport.phonkd.net";
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "syncthing";
          uri = "http://localhost:8384";
          insecure_skip_verify = true;
        }
      ];
    };
  };
}
