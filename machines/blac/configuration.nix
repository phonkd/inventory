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
    ./network.nix
    ../../modules/client/graphical.nix
    ../../modules/00-global-config.nix
    ../../modules/02-global-ssh.nix
    ../../modules/client/android.nix
    ../../modules/client/drone.nix
    ../../modules/client/games.nix
    ../../modules/client/audio.nix
    ../../modules/client/pulseaudio-client.nix
    #/tmp/work-setup.nix
    ../options.nix
    ./hyprland-session.nix
  ];
  sops.age = {
    keyFile = "/home/phonkd/.config/sops/age/keys.txt";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  services.hardware.bolt.enable = true;
  # Network configuration moved to network.nix
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

  boot.kernelParams = [
    #"pcie_aspm=off"
    "pci=noaer"
    "btusb.enable_autosuspend=n"
  ];

  users.users.phonkd = {
    isNormalUser = true;
    description = "phonkd";
    extraGroups = [
      "wheel"
      "dialout"
    ];
  };
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
  #programs.ssh.startAgent = false; # ssh-agent
  security.polkit.enable = true;
  environment.variables = {
    NIXOS_OZONE_WL = 1;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    # extraPackages = with pkgs; [
    #   nvidia-vaapi-driver
    #   libvdpau-va-gl
    #   libvdpau
    # ];
  };
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  environment.systemPackages = with pkgs; [
    #  nvidia-vaapi-driver
    sbctl
    cudatoolkit
  ];
  # environment.variables = {
  #   LIBVA_DRIVER_NAME = "nvidia";
  # };

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
