# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  services.paperless = {
    enable = true;
    address= "0.0.0.0";
  };
  services.caddy = {
    virtualHosts."paperless.int.phonkd.net".extraConfig = ''
      reverse_proxy :28981
    '';
  };
}
