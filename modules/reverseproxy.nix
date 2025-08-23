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
    enable = true;
    globalConfig = ''
      acme_dns cloudflare ${cfapikeytemp}
    '';
  };
}
