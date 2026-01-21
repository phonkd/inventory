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
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.teleport.phonkd.net,https://paperless.int.phonkd.net";
      ALLOWED_HOSTS = [
        "paperless.teleport.phonkd.net"
        "paperless.int.phonkd.net"
      ];
      PAPERLESS_CORS_ALLOWED_ORIGINS = "https://paperless.teleport.phonkd.net,https://paperless.int.phonkd.net";

      PAPERLESS_CORS_ALLOWED_HOSTS = "https://paperless.teleport.phonkd.net,https://paperless.int.phonkd.net";
    };
  };
  services.caddy = {
    virtualHosts."paperless.int.phonkd.net".extraConfig = ''
      reverse_proxy {
        to localhost:28981
        header_up Host "paperless.int.phonkd.net"
      }
    '';
  };
}
