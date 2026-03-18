{ config, pkgs, ... }:

{
  home.homeDirectory = "/home/phonkd";

  home.file.".config" = {
    source = builtins.path {
      path = ../dotconfig;
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
  home.file.".config/hypr/hyprlock.conf".source = ../dotconfig/hypr/hyprlock.conf;
  home.file.".config/hypr/workspaces.conf".source = ../dotconfig/hypr/workspaces.conf;


  sops.age = {
    keyFile = "/home/phonkd/.config/sops/age/keys.txt";
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

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = [
    ];
    sourceFirst = false;
    extraConfig = builtins.readFile ../dotconfig/hypr/hyprland.conf;
  };

  services.easyeffects.enable = true;

  xdg.desktopEntries."librewolf-work" = {
    name = "Work LibreWolf";
    exec = "librewolf -P work %u";
    icon = "librewolf";
    type = "Application";
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };
}
