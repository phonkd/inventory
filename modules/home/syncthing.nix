{ config, pkgs, ... }:

{
  services.syncthing = {
    package = if pkgs.stdenv.isDarwin then pkgs.syncthing-macos else pkgs.syncthing;
    enable = if pkgs.stdenv.isDarwin then false else true;
  };

}
