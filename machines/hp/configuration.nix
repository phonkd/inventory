# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
      ../../modules/00-global-config.nix
      ../../modules/02-global-ssh.nix
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "hp"; # Define your hostname.
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "sg";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  users.users.phonkd = {
    isNormalUser = true;
    description = "phonkd";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];
  system.stateVersion = "25.05"; # Did you read the comment?
  systemd.tmpfiles.rules = [
      "d /home/phonkd/tmp 0755 phonkd phonkd -"
  ];
  programs.ssh = {
    extraConfig = ''
      AddKeysToAgent yes
      Host *
        IdentityFile ~/.ssh/id_ed25519
    '';
  };
  programs.ssh.startAgent = true; #ssh-agent
  security.polkit.enable = true;
  environment.variables = {
    NIXOS_OZONE_WL=1;
  };
}
