{
  config,
  pkgs,
  lib,
  ...
}:

{
  microvm = {
    hypervisor = "vfkit";
    graphics.enable = true;
    mem = 4096;
    vcpu = 4;

    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 4096;
      }
      {
        mountPoint = "/home";
        image = "home.img";
        size = 8192;
      }
    ];

    shares = [
      {
        proto = "virtiofs";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];

    interfaces = [
      {
        type = "user";
        id = "usernet";
        mac = "02:00:00:01:01:01";
      }
    ];

    # vfkit doesn't support writableStoreOverlay
    # writableStoreOverlay = "/nix/.rw-store";
  };

  networking.hostName = "microvm-hypr";

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };
  console.keyMap = "sg";

  users.users.phonkd = {
    isNormalUser = true;
    description = "phonkd";
    extraGroups = [ "wheel" "video" ];
    password = "sml12345";
  };
  users.mutableUsers = true;
  security.sudo.wheelNeedsPassword = false;
  users.defaultUserShell = pkgs.zsh;

  # SSH server for waypipe + CocoaWay
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # No display manager - apps forwarded via waypipe + CocoaWay
  services.greetd.enable = false;

  # Bridge vsock port 22 to local SSH so host can connect via vsock
  systemd.services.vsock-ssh = {
    description = "vsock to SSH bridge";
    after = [ "sshd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat VSOCK-LISTEN:22,reuseaddr,fork TCP:127.0.0.1:22";
      Restart = "always";
    };
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Hyprland
  programs.hyprland.enable = true;
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

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    waypipe
    foot
    socat
    vim
    git
    killall
    lxqt.lxqt-policykit
    wl-clipboard
    waybar
    rofi
    swaybg
    grim
    slurp
    jq
    playerctl
    pavucontrol
    nautilus
    home-manager
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "fzf" ];
      theme = "robbyrussell";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  nixpkgs.config.allowUnfree = true;

  # microvm.nix masks nix-daemon but home-manager needs it for activation
  systemd.services.nix-daemon.enable = lib.mkForce true;
  systemd.sockets.nix-daemon.enable = lib.mkForce true;

  # Ensure /home/phonkd is created on the persistent volume
  systemd.tmpfiles.rules = [
    "d /home/phonkd 0755 phonkd users -"
  ];

  system.stateVersion = "25.05";
}
