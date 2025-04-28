# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.paperless = {
    enable = true;
    #address= "localhost";
    settings = {
      PAPERLESS_CSRF_TRUSTED_ORIGINS = [
        "http://localhost:28981"
        "https://paperless.teleport.phonkd.net"
      ] ;
      PAPERLESS_ALLOWED_HOSTS = [
        "http://localhost:28981"
        "https://paperless.teleport.phonkd.net"
      ] ;
      PAPERLESS_CORS_ALLOWED_ORIGINS = [
        "http://localhost:28981"
        "https://paperless.teleport.phonkd.net"
      ] ;
      PAPERLESS_CORS_ALLOWED_HOSTS = [
        "http://localhost:28981"
        "https://paperless.teleport.phonkd.net"
      ] ;
    };
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
