# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  phonkds.modules = {
    paperless = {
      ip = "127.0.0.1";
      port = 28981;
      dashboard = {
        enable = true;
        icon = "paperless";
      };
      traefik = {
        enable = true;
        auth = true;
        domain = "paperless.w.phonkd.net";
        ipfilter = false;
      };
      teleport = {
        enable = true;
        name = "paperless";
        rewriteHeaders = [
          "Host: paperless.teleport.phonkd.net"
        ];
      };
    };
  };

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    settings = {
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.teleport.phonkd.net,https://paperless.w.phonkd.net";
      ALLOWED_HOSTS = [
        "paperless.teleport.phonkd.net"
        "paperless.w.phonkd.net"
      ];
      PAPERLESS_CORS_ALLOWED_ORIGINS = "https://paperless.teleport.phonkd.net,https://paperless.w.phonkd.net";

      PAPERLESS_CORS_ALLOWED_HOSTS = "https://paperless.teleport.phonkd.net,https://paperless.w.phonkd.net";
    };
  };
}
