# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  users.users.phonkd.packages = with pkgs; [
    #  thunderbird
      kitty
      neovim
      git
      zed-editor
      unlauncher
      grimblast
      easyeffects
      cool-retro-term
      waybar
      btop
      cava
      lxqt.lxqt.policykit
      waypaper
      swaybg
      scrcpy
      google-chrome
      bat
      syncthing
      obsidian
      rofi-obsidian
      wdisplays
      cliphist
      hyprcursor
      xdg-desktop-portal-hyprland
      xdg-desktop-portal
      xdg-desktop-portal-wlr
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
      usbutlis
      yubikey-manager
      sshpass
      hyprlock
      spotify
      tree
      ipcalc
      virt-viewer
      home-manager
      sops
      dnsutils
      bibata-cursors
      nordic
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  programs.hyprland.enable = true;
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
