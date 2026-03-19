{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      theme = "Dracula";
      font-size = 16;
      confirm-close-surface = false;
      keybind = [ "super+enter=new_split:auto" ];
    };
  };
  programs.kitty = {
    enable = true;
    package = pkgs.unstable.kitty;
    settings = {
      pixel_scroll = "yes";
#      momentum_scroll = 0.96;
    };
  };
  programs.zsh = {
    enable = true;

    shellAliases = {
      stealmusic = "yt-dlp -x --audio-format mp3 --embed-thumbnail --embed-metadata";
    };
    siteFunctions = {
      cpp = ''
        cat "$1" | pbcopy
      '';
    };
    autosuggestion.enable = true;
    history.size = 1000000;
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    presets = [ "nerd-font-symbols" ];
    settings = {
      kubernetes = {
        disabled = false;
      };
    };
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
  programs.kubecolor = {
    enable = true;
    enableZshIntegration = true;
    #enableAlias = true;
  };
  home.packages = with pkgs; [
    nerd-fonts.symbols-only
  ];
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
}
