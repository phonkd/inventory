# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.paperless = {
    enable = true;
    address= "paperless.teleport.phonkd.net";
  };
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "paperless";
          uri = "http://127.0.0.1:28981";
          insecure_skip_verify = true;
        }
      ];
    };
  };
}
