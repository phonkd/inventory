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
    ./hardware-configuration.nix
    ./network.nix
    ../common-gui.nix
    ../../modules/02-global-ssh.nix
    ../../modules/client/android.nix
    ../../modules/client/drone.nix
    ../../modules/client/games.nix
    ../../modules/client/audio.nix
    ../../modules/client/pulseaudio-client.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.hardware.bolt.enable = true;

  services.displayManager.gdm.enable = true;
  services.xserver.enable = true; # Enabled here as gdm implies xserver often, though common-gui might not enforce it.

  boot.kernelParams = [
    #"pcie_aspm=off"
    "pci=noaer"
    "btusb.enable_autosuspend=n"
  ];

  users.users.phonkd.extraGroups = [ "dialout" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
  ];

  services.sunshine = {
    enable = false;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  services.ollama = {
    enable = true;
    #acceleration = "cuda";
  };

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Company Mouse Debounce Override]
    MatchName=*COMPANY*USB*Device*
    ModelBouncingKeys=1
  '';
}
