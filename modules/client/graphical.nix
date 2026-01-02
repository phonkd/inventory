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

  users.users.phonkd.packages = with pkgs; [
    #  thunderbird
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    kitty
    neovim
    zed-editor-fhs
    zed-discord-presence
    nixd
    nil
    grimblast
    easyeffects
    cool-retro-term
    waybar
    #unstable.waybar-lyric
    btop
    cava
    waypaper
    swaybg
    scrcpy
    google-chrome
    bat
    syncthing
    obsidian
    rofi
    rofi-obsidian
    rofi-systemd
    rofi-pulse-select
    rofi-rbw
    sqlite
    ponymix
    wdisplays
    cliphist
    hyprcursor
    hyprlandPlugins.hy3
    xdg-desktop-portal
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
    vesktop
    yt-dlp
    ffmpeg
    wget
    nautilus
    compose2nix
    codex
    kubectl
    kubectx
    kubectl-view-secret
    kube-capacity
    nwg-displays
    nvtopPackages.full
    talosctl
    kubernetes-helm
    clusterctl
    kubectx
    kconf
    kustomize
    kustomize-sops
    k9s
    stern
    winbox4
    betaflight-configurator
    netbird
    moonlight-qt
    ookla-speedtest
    iperf3
    terraform
    minio-client
    iftop
    prek
    argocd
    gemini-cli-bin
    comma
    yq
    alacritty-graphics
    hyprviz
    virt-viewer
  ];
  environment.systemPackages = with pkgs; [
    unstable.proton-vpn-cli
    unstable.protonvpn-gui
    lxqt.lxqt-policykit
  ];
  networking.firewall.checkReversePath = false;
  #services.netbird.enable = true;
  programs.light.enable = true;
  users.extraGroups.video.members = [ "phonkd" ];
  programs.winbox = {
    enable = true;
    openFirewall = true;
  };
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };
  # Install firefox.
  programs.firefox.enable = true;
  programs.zoxide.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.gnome.sushi.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # List packages installed inff system profile. To search, run:
  # $ nix search wget

  ## file manager and usb mount

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true; # Thumbnail support for images
  services.devmon.enable = true;
  #wireguard need this:
  services.resolved.enable = false;
  programs.xfconf.enable = true;
  # programs.thunar.enable = true;
  # programs.thunar.plugins = with pkgs.xfce; [
  #     thunar-archive-plugin
  #     thunar-volman
  # ];
  services.syncthing = {
    enable = true;
    user = "phonkd";
    dataDir = "/home/phonkd/";
    configDir = "/home/phonkd/.config/syncthing";
  };
  security.polkit.enable = true;
  virtualisation.podman.enable = true;
  #virtualisation.docker.enable = true;
  programs.git = {
    enable = true;
    config = {
      user.name = "Elis";
      user.email = "enst18.12@gmail.com";
    };
  };
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
  programs.zsh.ohMyZsh.plugins = [
    "kube-ps1"
  ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
