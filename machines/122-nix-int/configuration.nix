# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).asdf

{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./network.nix
    ../../modules/02-global-ssh.nix
    ../../modules/00-global-config.nix
    ../../modules/01-vm-config.nix
    ./wgnotez.nix
    #../../modules/reverseproxy.nix
    ./caddy-int.nix
    ../../modules/paperless.nix
    ../../modules/syncthing.nix
    ../../modules/glances.nix
    ../../modules/shares.nix
    ../../modules/dns.nix
  ];
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "zyxel";
          uri = "https://192.168.1.1";
          insecure_skip_verify = true;
        }
      ];
    };
  };
  programs.fzf.fuzzyCompletion = true;
}
