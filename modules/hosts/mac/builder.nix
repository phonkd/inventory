 { config, pkgs, lib, ... }:
 let
   system = "aarch64-darwin";
   pkgs-darwin = import (builtins.fetchTarball {
     # nixpkgs-24.05-darwin
     url = "https://github.com/nixos/nixpkgs/archive/abddaec7149b62550305c0d20cf9651f8413da77.tar.gz";
     sha256 = "0267b96a20vhkr9wa3z94iqc7jn61ij9azibzsc9drppsf2dzwnm";
   }) { inherit system; };
 in
 {
  nix.package = pkgs.nix;
  nix.linux-builder.enable = true;
  nix.settings.trusted-users = [ "@admin" ];
  nix.linux-builder.package = pkgs-darwin.darwin.linux-builder;
  environment.systemPackages = [
    pkgs.vim
    pkgs.devbox
    pkgs.nixos-rebuild-ng
  ];
 }
