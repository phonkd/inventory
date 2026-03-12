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
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''
        [░▒▓](#a3aed2)[  ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$kubernetes[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)
        $character
      '';
      directory = {
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = ".../";
      };
      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };
      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };
      kubernetes = {
        disabled = false;
        style = "bg:#212736";
        format = "[[ ☸ $context( \\($namespace\\)) ](fg:#769ff0 bg:#212736)]($style)";
      };
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#1d2230";
        format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
      };
    };
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.kubecolor = {
    enable = true;
    enableZshIntegration = true;
  };
}
