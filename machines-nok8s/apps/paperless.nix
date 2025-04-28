# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.paperless = {
    enable = true;
    address= "localhost";
  };
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "paperless";
          uri = "http://localhost:28981";
          insecure_skip_verify = true;
        }
      ];
    };
  };
}
