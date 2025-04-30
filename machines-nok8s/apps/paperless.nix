# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.paperless = {
    enable = true;
    address= "0.0.0.0";
    settings = {
      PAPERLESS_CSRF_TRUSTED_ORIGINS = [
        "https://paperless.teleport.phonkd.net"
        "https://paperless.int.phonkd.net"
      ] ;
      PAPERLESS_ALLOWED_HOSTS = [
        "paperless.teleport.phonkd.net"
        "paperless.int.phonkd.net"
      ];
      PAPERLESS_CORS_ALLOWED_ORIGINS = [
        "https://paperless.teleport.phonkd.net"
        "https://paperless.int.phonkd.net"
      ];
      PAPERLESS_CORS_ALLOWED_HOSTS = [
        "https://paperless.teleport.phonkd.net"
        "https://paperless.int.phonkd.net"
        ];
    };
  };
  services.caddy = {
    virtualHosts."paperless.int.phonkd.net".extraConfig = ''
      reverse_proxy {
        to localhost:28981
        header_up Host "paperless.teleport.phonkd.net"
      }
    '';
  };
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "paperless";
          uri = "http://localhost:28981";
          insecure_skip_verify = true;
          rewrite = {
            headers = [
              "Host: paperless.teleport.phonkd.net"
            ];
          };
        }
      ];
    };
  };
}
