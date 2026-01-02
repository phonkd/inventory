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

  users.users.phonkd.packages = with pkgs; [
    lunar-client
    prismlauncher
  ];
  programs.steam.enable = true;

}
