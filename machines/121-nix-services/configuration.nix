# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./network.nix
    ../../modules/02-global-ssh.nix
    ../../modules/00-global-config.nix
    ../../modules/01-vm-config.nix
    #../../modules/reverseproxy.nix
    ../../modules/vaultwarden.nix
    ../../modules/immich.nix
    ../../modules/share.nix
    ../../modules/o11y/o11y.nix
    ../../modules/o11y/alloy.nix
    ../../modules/ddns.nix
  ];
  services.caddy = {
    package = pkgs.caddy.withPlugins {
      hash = "sha256-p9AIi6MSWm0umUB83HPQoU8SyPkX5pMx989zAi8d/74=";
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];
}
