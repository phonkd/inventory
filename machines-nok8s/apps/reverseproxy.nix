{ config, pkgs, lib, ... }:
let
  cfapikeytemp = if builtins.pathExists config.sops.secrets."cfapikey".path then
                    builtins.readFile config.sops.secrets."cfapikey".path
                  else
                    "default_auth_token_placeholder";
in
{
  sops.secrets.cfapikey = {};
  services.caddy = {
    package = pkgs.unstable.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-Nwm4kzAmmu+UZTJB5npWdwfgoj3giHIEWIgDF6ff+dY=";
    };
    enable = true;
    globalConfig = ''
      acme_dns cloudflare ${cfapikeytemp}
    '';
  };
}
