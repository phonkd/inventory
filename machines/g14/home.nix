{ config, pkgs, lib, ... }:

let
  unstable = import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz";
  }) { };
in
{
  imports = [
    ../common-home.nix
  ];

  home.activation.createMonitorsConf = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f $HOME/.config/hypr/monitors.conf ]; then
      touch $HOME/.config/hypr/monitors.conf
      echo "monitor=,preferred,auto,1.25" > $HOME/.config/hypr/monitors.conf
    fi
  '';

  home.packages = [
    unstable.waybar-lyric
    (pkgs.writeShellScriptBin "waybar-hottest-cpu" ''
      #!/usr/bin/env bash
      set -euo pipefail

      sensors_bin="${pkgs.lm_sensors}/bin/sensors"
      jq_bin="${pkgs.jq}/bin/jq"

      json="$($sensors_bin -j 2>/dev/null || true)"

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


}