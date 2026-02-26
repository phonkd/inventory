{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../modules/client/graphical.nix
    ../modules/00-global-config.nix
    ./options.nix
  ];

  sops.age = {
    keyFile = "/home/phonkd/.config/sops/age/keys.txt";
  };

  # Network configuration should be imported in the host config usually,
  # but since it's common 'network.nix' in the local dir, we leave it to the host.

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };
  console.keyMap = "sg";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.phonkd = {
    isNormalUser = true;
    description = "phonkd";
    extraGroups = [ "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";

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

  security.polkit.enable = true;

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau-va-gl
      libvdpau
    ];
  };

  environment.systemPackages = with pkgs; [
    sbctl
    nvidia-vaapi-driver
  ];
  services.displayManager.sessionPackages = [
    (pkgs.runCommand "hyprland-session"
      {
        passthru.providedSessions = [ "hyprland" ];
      }
      ''
              mkdir -p $out/share/wayland-sessions
              cat <<EOF > $out/share/wayland-sessions/hyprland.desktop
        [Desktop Entry]
        Name=Hyprland
        Comment=An intelligent dynamic tiling Wayland compositor
        Exec=Hyprland
        Type=Application
        DesktopNames=Hyprland
        EOF
      ''
    )
  ];
}
