{ config, pkgs, ... }:

let
  unstable = import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz";
  }) { };
in
{
  home = {
    username = "phonkd";
    homeDirectory = "/home/phonkd";
    stateVersion = "25.05";

    file.".config" = {
      source = ../../modules/dotconfig;
      recursive = true;
      force = true;
    };

    sessionVariables = {
      # EDITOR = "emacs";
    };

    packages = [
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      unstable.waybar-lyric
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
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
