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
        path = ../modules/dotconfig;
        name = "dotconfig";
        filter = 
          path: type:
          let
            baseName = baseNameOf path;
          in
          baseName != "hypr";
      };
      recursive = true;
      force = true;
    };

    # Copy hypr files except hyprland.conf
    file.".config/hypr/hyprlock.conf".source = ../modules/dotconfig/hypr/hyprlock.conf;
    file.".config/hypr/workspaces.conf".source = ../modules/dotconfig/hypr/workspaces.conf;
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

  # Disable news notifications
  news.display = "silent";

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hy3
    ];
    sourceFirst = false;
    extraConfig = builtins.readFile ../modules/dotconfig/hypr/hyprland.conf;
  };

  programs.home-manager.enable = true;

  services.easyeffects.enable = true;
}
