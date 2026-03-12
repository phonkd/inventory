{ config, pkgs, ... }:

{
  imports = [
    ./terminal.nix
    ./editors.nix
  ];
  home = {
    username = "phonkd";
    stateVersion = "25.05";
    enableNixpkgsReleaseCheck = false;
  };

  news.display = "silent";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nicotine-plus
    localsend
  ];

}
