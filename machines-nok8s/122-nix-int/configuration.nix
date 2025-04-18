# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).asdf

{ ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./rebuildah.nix
      ./network.nix
      ./vm.nix
      ../../machine-base/ssh.nix
      ../../machine-base/base.nix
      ../../machine-base/base-hardware-configuration.nix
      ./wgez.nix
    ];
}
