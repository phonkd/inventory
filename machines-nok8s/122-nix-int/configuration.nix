# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).asdf

{ ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./network.nix
      ./vm.nix
      ../../machine-base/ssh.nix
      ../../machine-base/base.nix
      ../../machine-base/base-hardware-configuration.nix
      ./wgez.nix
      ../apps/reverseproxy.nix
      ./caddy-int.nix
      ../apps/paperless.nix
      ../apps/syncthing.nix
      ../apps/board.nix
    ];
    services.teleport.settings = {
      app_service = {
        enabled = true;
        apps = [
          {
            name = "wg";
            uri = "http://localhost:51821";
            insecure_skip_verify = true;
          }
        ];
      };
    };
}
