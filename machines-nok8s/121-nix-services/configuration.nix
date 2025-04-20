# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./rebuildah.nix
      ./network.nix
      ./vm.nix
      ./ssh.nix
      ../../machine-base/base.nix
      ../../machine-base/base-hardware-configuration.nix
      ../apps/reverseproxy.nix
      ../apps/vaultwarden.nix
      ../apps/teleport.nix
      ../apps/immich.nix
      ../apps/zipline.nix
    ];
}
