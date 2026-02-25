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
    ../common-gui.nix
    ../blac/hyprland-session.nix
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

  hardware.nvidia.open = false;
  programs.rog-control-center.enable = true;
  environment.systemPackages = with pkgs; [
    displaylink
  ];
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.evdi ];
    kernelModules = [
      "typec_ucsi"
      "ucsi_acpi"
    ];
    initrd = {
      # List of modules that are always loaded by the initrd.
      kernelModules = [
        "evdi"
      ];
    };
  };
  systemd.services.displaylink-server = {
    enable = true;
    requires = [ "systemd-udevd.service" ];
    after = [ "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
      User = "root";
      Group = "root";
      Restart = "on-failure";
      RestartSec = 5; # Wait 5 seconds before restarting
    };
  };
}
