{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/common-home.nix
  ];

  home.homeDirectory = "/Users/phonkd";
}
