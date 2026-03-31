# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  phonkds.modules = {
    memos = {
      ip = "127.0.0.1";
      port = 5230;
      dashboard = {
        enable = true;
        icon = "memos";
      };
      traefik = {
        enable = true;
        auth = true;
        domain = "memos.w.phonkd.net";
        ipfilter = false;
      };
      teleport = {
        enable = false;
      };
    };
  };

  services.memos = {
    enable = true;
  };
}
