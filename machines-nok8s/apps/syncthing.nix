# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.syncthing.enable = true;
  options = {
    listenAddresses = [
      "0.0.0.0:8384"
      "syncthing.teleport.phonkd.net"
    ];
  };
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "syncthing";
          uri = "localhost:8384";
          insecure_skip_verify = true;
        }
      ];


    };
  };
}
