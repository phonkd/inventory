{ config, pkgs, ... }:

{
  home = {
    username = "phonkd";
    homeDirectory = "/home/phonkd";
    stateVersion = "25.05";

    # Disable the nixpkgs release check warning
    enableNixpkgsReleaseCheck = false;

    file.".config" = {
      source = builtins.path {
        path = ../../modules/dotconfig;
        name = "dotconfig";
        filter = # this filter is needed for the hyprland module being able to independently manage the hyprland config file existing in the same dir without it being overwritten by the .config recursive import
          path: type:
          let
            baseName = baseNameOf path;
          in
          baseName != "hypr";
      };
      recursive = true;
      force = true;
    };

    # Copy hypr files except hyprland.conf (managed by wayland.windowManager.hyprland)
    file.".config/hypr/monitors.conf".source = ../../modules/dotconfig/hypr/monitors.conf;
    file.".config/hypr/hyprlock.conf".source = ../../modules/dotconfig/hypr/hyprlock.conf;
    file.".config/hypr/workspaces.conf".source = ../../modules/dotconfig/hypr/workspaces.conf;

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

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hy3
    ];
    # Use the config file from dotconfig directly
    sourceFirst = false;
    extraConfig = builtins.readFile ../../modules/dotconfig/hypr/hyprland.conf;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
