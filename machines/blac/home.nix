{ config, pkgs, ... }:

{
  home = {
    username = "phonkd";
    homeDirectory = "/home/phonkd";
    stateVersion = "25.05";

    # Disable the nixpkgs release check warning
    enableNixpkgsReleaseCheck = false;

    file.".config" = {
      source = ../../modules/dotconfig;
      recursive = true;
      force = true;
    };

    sessionVariables = {
      # EDITOR = "emacs";
    };

    packages = with pkgs; [
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      waybar-lyric
    ];
  };

  # Qt configuration
  qt = {
    enable = false;
    platformTheme.name = "gtk";
    style = {
      name = "Nordic-darker";
      package = pkgs.nordic;
    };
  };

  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      package = pkgs.nordic;
      name = "Nordic-darker";
    };
    iconTheme = {
      package = pkgs.kora-icon-theme;
      name = "kora-pgrey";
    };
  };

  # Disable news notifications to avoid build-news.nix error in flakes
  news.display = "silent";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
