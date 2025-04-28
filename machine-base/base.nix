# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’)

{ config, pkgs, lib, ... }:
{
  imports = [
    ../machines-nok8s/apps/rebuildah/rebuildah.nix
    ../machines-nok8s/apps/sops.nix
    ../machines-nok8s/apps/alloy.nix
    ../machines-nok8s/apps/teleport.nix
  ];
  # services.cron.systemCronJobs = [
  #   "*/3 * * * * root nix-experiment -repopath /tmp/kek -nixconfig machines-nok8s/10112-dev-vm/configuration.nix -repourl https://github.com/phonkd/inventory.git -ntfyurl https://notify.arnsi.ch/seltest -ntfytoken"
  # ];
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  nixpkgs.config.allowUnfree = true;
  networking.firewall.enable = true;
  system.stateVersion = "24.11"; # Did you read the comment?
  services.qemuGuest.enable = true;
  sops.age.keyFile = /home/phonkd/.config/sops/age/keys.txt;
  sops.defaultSopsFile = ../machines-nok8s/apps/ocis/secrets/secret.yaml;
}
