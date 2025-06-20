# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  cfapikeytemp = if builtins.pathExists config.sops.secrets."cfapikey".path then
                    builtins.readFile config.sops.secrets."cfapikey".path
                  else
                    "default_auth_token_placeholder";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./network.nix
      ./vm.nix
      ./ssh.nix
      ../../machine-base/base.nix
      ../../machine-base/base-hardware-configuration.nix
      ../apps/reverseproxy.nix
      ../apps/vaultwarden.nix
      ../apps/immich.nix
      ../apps/share.nix
      ../apps/flowtime.nix
      ../apps/mc.nix
    ];
  services.caddy = {
    package =  pkgs.caddy.withPlugins {
      hash = "sha256-Gsuo+ripJSgKSYOM9/yl6Kt/6BFCA6BuTDvPdteinAI=";
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
    };
  };
}
