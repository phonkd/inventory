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
    /etc/nixos/hardware-configuration.nix
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/asus/zephyrus/ga401"
    ./network.nix
    ./g14-fixes.nix
    ../common-gui.nix
    ../../modules/client/audio.nix
    ../../modules/client/pulseaudio-client.nix
    ../../modules/dns.nix
  ];

  # Bootloader.
  boot.loader.limine.enable = true;
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.displayManager.sddm.enable = true;
  services.xserver.enable = true;
}
