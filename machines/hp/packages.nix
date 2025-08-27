# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{

  users.users.phonkd.packages = with pkgs; [
    #  thunderbird
      kitty
      neovim
      git
      zed-editor
      grimblast
      easyeffects
      cool-retro-term
      waybar
      btop
      cava
      waypaper
      swaybg
      scrcpy
      google-chrome
      bat
      syncthing
      obsidian
      rofi-obsidian
      nwg-displays
      cliphist
      hyprcursor
      xdg-desktop-portal-hyprland
      xdg-desktop-portal
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      obs-studio
      vlc
      wireguard-tools
      exfat
      dracula-theme
      swappy
      slurp
      wl-clipboard
      jq
      nwg-look
      yubikey-manager
      sshpass
      hyprlock
      spotify
      tree
      ipcalc
      virt-viewer
      home-manager
      sops
      pulseaudio
      dnsutils
      bibata-cursors
      nordic
      ulauncher
      discord
      zsh
      fzf
      playerctl
      vesktop
      pavucontrol
    ];
  services.flatpak.enable = true;
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    lxqt.lxqt-policykit
  ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  programs.hyprland.enable = false;
  hardware.nvidia.open = false;

  ## file manager and usb mount

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true; # Thumbnail support for images
  services.devmon.enable = true;
  #wireguard need this:
  services.resolved.enable = false;
  programs.xfconf.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
  ];
  services.syncthing = {
    enable = true;
    user = "phonkd";
    dataDir = "/home/phonkd/";
    configDir = "/home/phonkd/.config/syncthing";
  };
  security.polkit.enable = true;
  virtualisation.podman.enable = true;
  programs.git = {
     enable = true;
     config = {
       user.name  = "Elis";
       user.email = "enst18.12@gmail.com";
     };
  };
}
