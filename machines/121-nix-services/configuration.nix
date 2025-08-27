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
      ../../modules/02-global-ssh.nix
      ../../modules/00-global-config.nix
      ../../modules/01-vm-config.nix
      ../../modules/reverseproxy.nix
      ../../modules/vaultwarden.nix
      ../../modules/immich.nix
      ../../modules/share.nix
      ../../modules/flowtime.nix
      #../../modules/rustfs.nix
      ../../modules/o11y.nix
      ../../modules/alloy.nix
    ];
  services.caddy = {
    package =  pkgs.caddy.withPlugins {
      hash = "sha256-S1JN7brvH2KIu7DaDOH1zij3j8hWLLc0HdnUc+L89uU=";
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
    };
  };
}
