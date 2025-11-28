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
    ../../modules/client/graphical.nix
    ../../modules/00-global-config.nix
    ../../modules/client/android.nix
    ../options.nix
  ];
  sops.age = {
    keyFile = "/home/phonkd/.config/sops/age/keys.txt";
  };
  # Bootloader.
  boot.loader.limine.enable = true;
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Network configuration moved to network.nix
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;

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
    extraGroups = [
      "wheel"
    ];
  };
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;
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
  programs.ssh.startAgent = true; # ssh-agent
  security.polkit.enable = true;
  environment.variables = {
    NIXOS_OZONE_WL = 1;
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
  programs.hyprland.enable = true;
  hardware.nvidia.open = false;
  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    sbctl
  ];
  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
  };

}
