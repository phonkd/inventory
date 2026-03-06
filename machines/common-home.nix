{ config, pkgs, ... }:

{
  home = {
    username = "phonkd";
    stateVersion = "25.05";
    enableNixpkgsReleaseCheck = false;
  };

  news.display = "silent";

  programs.git = {
    enable = true;
    userName = "Elis";
    userEmail = "phonkd@phonkd.net";
  };

  programs.home-manager.enable = true;

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
  home.packages = with pkgs; [
    nil
    nicotine-plus
    kew
    localsend
  ];
  programs.neovim = {
    enable = true;
    vimAlias = true;
    # plugins = with pkgs.vimPlugins;
    # [
    #   yankring
    #   vim-nix
    #   markdown-nvim
    #   markdown-preview-nvim
    # ];

  };

}
