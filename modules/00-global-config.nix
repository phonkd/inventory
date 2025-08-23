{ config, pkgs, lib, ... }:
{
  imports = [
    #../machines-nok8s/apps/sops.nix
    ./alloy.nix
    ./teleport.nix
    #(modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  nixpkgs.config.allowUnfree = true;
  networking.firewall.enable = true;
  system.stateVersion = "25.05"; # Did you read the comment?
  services.qemuGuest.enable = true;
  sops.age.keyFile = /home/phonkd/.config/sops/age/keys.txt;
  sops.defaultSopsFile = ./global-secrets/secret.yaml;
  environment.systemPackages = [
      pkgs.git
  ];
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-path/pci-0000:01:01.0-scsi-0:0:0:0-part/by-partnum/1";
      fsType = "ext4";
      autoResize = true;
    };
  boot.growPartition = true;
  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
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
    extraGroups = [ "networkmanager" "wheel" ];
    password = "sml12345";
  };
  users.mutableUsers = true;
  security.sudo.wheelNeedsPassword = false;
  programs.git = {
     enable = true;
     config = {
       user.name  = "Elis";
       user.email = "enst18.12@gmail.com";
     };
  };
}
