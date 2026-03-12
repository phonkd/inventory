{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      theme = "Adventure";
      font-size = 16;
      confirm-close-surface = false;
      keybind = [ "super+enter=new_split:right" ];
    };
  };
}
