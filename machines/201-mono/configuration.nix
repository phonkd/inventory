# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).asdf

{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./network.nix
    ../../modules/02-global-ssh.nix
    ../../modules/00-global-config.nix
    ../../modules/01-vm-config.nix
    #./keycloak.nix
    ./traefik.nix
    #../../modules/renovate.nix
    ../../modules/s3-garage.nix
    ../../modules/shares.nix
    ../../modules/arr.nix
    ../../modules/dns.nix
    ../../modules/syncthing.nix
    ../../modules/vaultwarden.nix
    ./wgnotez.nix
  ];
  boot.loader.grub.device = "/dev/vda";
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "zyxel";
          uri = "https://192.168.1.1";
          insecure_skip_verify = true;
        }
        {
          name = "oldblac";
          uri = "https://192.168.1.47:8006";
          insecure_skip_verify = true;
        }
      ];
    };
  };
}
