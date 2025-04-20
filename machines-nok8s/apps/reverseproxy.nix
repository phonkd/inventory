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
      plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20250228175314-1fb64108d4de" ];
      hash = "sha256-pfh9DXUj35jlAntkWc4D5wuW04xxQfM1rZ4KFauMzvc=";
    };
    enable = true;
    globalConfig = ''
      acme_dns cloudflare ${cfapikeytemp}
    '';
  };
}
