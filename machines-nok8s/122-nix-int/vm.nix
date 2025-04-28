{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
    sops
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # fileSystems."/dev/sda1".autoResize = true;
  # virtualisation.fileSystems."/dev/sda1".fsType = "ext4";
  #sops.secrets."kek/ocisjwt" = {};

}
