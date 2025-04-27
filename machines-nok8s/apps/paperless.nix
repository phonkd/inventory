# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.paperless = {
    enable = true;
    port = 28981;
    #consumptionDirIsPublic = true;
    address = "paperless.int.phonkd.net";
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };
  };
  services.caddy = {
    virtualHosts."paperless.int.phonkd.net".extraConfig = ''
      reverse_proxy :28981
    '';
  };
}
