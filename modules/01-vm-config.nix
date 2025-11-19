{ config, pkgs, lib, ... }:
let
  isVM = lib.elem "vm" config.label.labels;
in
{
  imports = [
    #../machines-nok8s/apps/sops.nix
    ./o11y/alloy.nix
    #(modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  nixpkgs.config.allowUnfree = true;
  networking.firewall.enable = true;
  system.stateVersion = "25.05"; # Did you read the comment?
  services.qemuGuest.enable = true;
  sops.age = lib.mkIf isVM {
    keyFile = "/home/phonkd/.config/sops/age/keys.txt";
  };
  sops.defaultSopsFile = ./global-secrets/secret.yaml;
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
}
