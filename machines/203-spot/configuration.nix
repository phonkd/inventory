# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).asdf

{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./network.nix
    ../../modules/02-global-ssh.nix
    ../../modules/00-global-config.nix
    ../../modules/01-vm-config.nix
    ../../modules/gigaplayer.nix
    ../../modules/applist.nix
  ];
  boot.loader.grub.device = "/dev/vda";
}
