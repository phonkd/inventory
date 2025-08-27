{ config, pkgs, ... }:

{
  home.username = "phonkd";
  home.homeDirectory = "/home/phonkd";
  qt.enable = false;
  gtk.enable = true;
  qt.platformTheme.name = "gtk";
  qt.style.name = "Nordic-darker";
  qt.style.package = pkgs.nordic;

  gtk.theme.package = pkgs.nordic;
  gtk.theme.name = "Nordic-darker";
  gtk.iconTheme.package = pkgs.kora-icon-theme;
  gtk.iconTheme.name = "kora-pgrey";
  home.stateVersion = "25.05"; # Please read the comment before changing.
  home.packages = [
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    hyprland
  ];

  home.file = {
  };
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
  wayland.windowManager.hyprland = {
    enable = true;
    # package = null;
    # portalPackage = null;
    settings = {
    source = "${config.xdg.configHome}/hypr/monitors.conf";
    misc = {
      vrr = 1;
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
    };

    env = [
      "XCURSOR_SIZE,40"
      "XCURSOR_THEME,Bibata-Modern-Amber"
      "HYPRCURSOR_SIZE,40"
      "HYPRCURSOR_THEME,Bibata-Modern-Amber"
      "MOZ_ENABLE_WAYLAND,1"
      "QT_CURSOR_THEME,Bibata-Modern-Amber"
      "QT_CURSOR_SIZE,40"
    ];

    exec-once = [
      "waybar --config ~/.config/waybar/config_laptop & ulauncher --hide-window"
      "lxqt-policykit-agent"
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      ".config/clipsync.sh watch"
      "easyeffects --gapplication-service"
    ];

    exec = [
        "wpaperd -d"
    ];
    general = {
      gaps_in = 5;
      gaps_out = 15;
      border_size = 3;
      "col.active_border" = "rgba(f1f1f1aa)";
      "col.inactive_border" = "rgba(000000aa)";
      layout = "dwindle";
    };

    decoration = {
      rounding = 15;
      active_opacity = 0.8;
      inactive_opacity = 0.6;
      fullscreen_opacity = 1.0;
      blur = {
        enabled = true;
        size = 4;
        passes = 3;
        vibrancy = 0.8;
        ignore_opacity = true;
      };
    };

    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master.new_status = "master";
    input = {
      kb_layout = "ch";
      kb_variant = "de_nodeadkeys";
      follow_mouse = 1;
      sensitivity = 0;
      touchpad = {
          natural_scroll = false;
          disable_while_typing = false;
      };
    };

    gestures.workspace_swipe = true;

    device = [
    {
      name = "logitech-usb-receiver";
      sensitivity = -0.4;
      accel_profile = "flat";
    }
    {
      name = "haste-2-wireless-mouse";
      sensitivity = -0.4;
      accel_profile = "flat";
    }
    {
      name = "hp,-inc-hyperx-pulsefire-haste-2-wireless";
      sensitivity = -0.4;
      accel_profile = "flat";
    }
    ];

    "$mainMod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "thunar";
    "$menu" = "rofi --show drun";

    bind = [
      "$mainMod, Return, exec, $terminal"
      "$mainMod, Q, killactive,"
      "$mainMod SHIFT, E, exit"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, W, exec, firefox"
      "$mainMod, Z, exec, WAYLAND_DISPLAY='' zed"
      "$mainMod, o, exec, rofi -show rofi-obsidian:rofi-obsidian"
      "$mainMod, 0, exec, rofi -show rofi-sound -modi \"rofi-sound:~/.config/i3/rofi-sound-output-chooser\""
      "$mainMod, u, exec, rofi-bluetooth"
      "SUPER, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
      "$mainMod Shift, o, exec, ~/.config/rofi-code"

      "$mainMod, i, exec, light -A 5"
      "$mainMod SHIFT, i, exec, light -U 5"
      "$mainMod, b, exec, playerctl play-pause"
      "$mainMod, n, exec, playerctl next"
      "$mainMod SHIFT, n, exec, playerctl previous"
      "$mainMod, m, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
      "$mainMod SHIFT, m, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
      "$mainMod, s, exec, wpaperctl next"
      "$mainMod, c, exec, grimblast save area - | swappy -f -"
      "$mainMod, SPACE, togglefloating,"
      "$mainMod, D, exec, ulauncher-toggle"
      "$mainMod, F, fullscreen, 2"
      "$mainMod, y, exec, hyprlock"
      "$mainMod, r, exec, /home/phonkd/.config/rofi-yk"
      "$mainMod, h, movefocus, l"
      "$mainMod, l, movefocus, r"
      "$mainMod, k, movefocus, u"
      "$mainMod, j, movefocus, d"
      "SUPER SHIFT,h, movewindow, l"
      "SUPER SHIFT,l, movewindow, r"
      "SUPER SHIFT,k, movewindow, u"
      "SUPER SHIFT,j, movewindow, d"
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"
      "$mainMod SHIFT, w, togglegroup"
      "$mainMod, right, changegroupactive, f"
      "$mainMod, left, changegroupactive, b"
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
    windowrulev2 = [
      "bordercolor rgba(F40009AA) rgba(40009AA),floating:1"
      "suppressevent maximize, class:.*"
      "float,title:(Authentication Required)"
      "stayfocused,title:(Authentication Required)"
      "stayfocused,class:(ulauncher)"
    ];
  };
}
