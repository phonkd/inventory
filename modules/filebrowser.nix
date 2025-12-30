# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.filebrowser = {
    enable = true;
    settings = {
      database = "/mnt/Shares/filebrowser/db";
      root = "/mnt/Shares/filebrowser/root";
      port = 8088;
    };
  };
}
