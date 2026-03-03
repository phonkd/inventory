{ config, pkgs, ... }:

{
  imports = [
    ../common-home.nix
  ];

  home.homeDirectory = "/Users/phonkd";
}
