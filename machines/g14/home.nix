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
      (pkgs.writeShellScriptBin "waybar-hottest-cpu" ''
        #!/usr/bin/env bash
        set -euo pipefail

        sensors_bin="${pkgs.lm_sensors}/bin/sensors"
        jq_bin="${pkgs.jq}/bin/jq"

        json="$("$sensors_bin" -j 2>/dev/null || true)"

        if [[ -z "$json" ]]; then
          echo '{"text":"--","tooltip":"No sensor data","class":["sensor-missing"]}'
          exit 0
        fi

        temp="$(printf '%s\n' "$json" | "$jq_bin" -r '
          ([
             to_entries[]
             | select(.key | test("(?i)(coretemp|k10temp|zenpower|amdtemp)"))
             | .value
             | .. | objects
             | to_entries[]
             | select(.key | test("^temp[0-9]+_input$"))
             | .value
           ] | max) // empty
        ')"

        if [[ -z "$temp" || "$temp" == "null" ]]; then
          echo '{"text":"--","tooltip":"CPU temperature unavailable","class":["sensor-missing"]}'
          exit 0
        fi

        temp_int="$(printf '%.0f' "$temp")"

        if (( temp_int >= 90 )); then
          cls="critical"
          icon=""
        elif (( temp_int >= 85 )); then
          cls="warning"
          icon=""
        else
          cls="normal"
          icon=""
        fi

        printf '{"text":"%s %s°C","tooltip":"Hottest CPU sensor %s°C","class":["%s"]}\n' "$icon" "$temp_int" "$temp_int" "$cls"
      '')
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
}
