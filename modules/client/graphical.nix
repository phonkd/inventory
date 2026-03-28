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
    zed-editor-fhs
    zed-discord-presence
    grimblast
    grim
    hyprshot
    cool-retro-term
    waybar
    #unstable.waybar-lyric
    btop
    waypaper
    swaybg
    scrcpy
    google-chrome
    bat
    obsidian
    rofi
    rofi-obsidian
    rofi-systemd
    rofi-rbw
    sqlite
    wdisplays
    cliphist
    hyprcursor
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
    dnsutils
    bibata-cursors
    nordic
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
    # argocd
    comma
    yq
    alacritty-graphics
    hyprviz
    virt-viewer
    usbutils
  ];
  environment.systemPackages = with pkgs; [
    unstable.proton-vpn-cli
    unstable.protonvpn-gui
    lxqt.lxqt-policykit
  ];
  networking.firewall.checkReversePath = false;
  #services.netbird.enable = true;
  hardware.acpilight.enable = true;
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
  programs.zoxide.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.gnome.sushi.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.gpu-screen-recorder.enable = true;
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
  # services.syncthing = {
  #   enable = true;
  #   #configDir = "/home/phonkd/.config/syncthing";
  #   user = "phonkd";
  #   dataDir = "/home/phonkd/";

  #   settings.folders."browser-profiles" = {
  #     path = "/home/phonkd/browser-profiles";
  #     ignorePerms = false;
  #   };
  # };


  security.polkit.enable = true;
  virtualisation.podman.enable = true;
  #virtualisation.docker.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
  programs.zsh.ohMyZsh.plugins = [
    # "kube-ps1" # Disabling to improve shell startup time
  ];
  hardware.bluetooth = {
    enable = true;
  };
  services.blueman.enable = true;

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "phonkd" ];

  users.users.phonkd.extraGroups = [ "libvirtd" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;
}
