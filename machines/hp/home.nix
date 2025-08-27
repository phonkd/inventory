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
  ];

  home.file = {
  };
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      settings = {
        # Keybindings
        bind = [
          "SUPER SHIFT,h, movewindow, l"
          "SUPER SHIFT,l, movewindow, r"
          "SUPER SHIFT,k, movewindow, u"
          "SUPER SHIFT,j, movewindow, d"
          # Workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          # "$mainMod, 0, workspace, 10"
          # Move window to workspace
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
          # Groups
          "$mainMod SHIFT, w, togglegroup"
          "$mainMod, right, changegroupactive, f"
          "$mainMod, left, changegroupactive, b"
          # Scroll through workspaces
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ];
        # Mouse binds
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        # Window rules
        windowrulev2 = [
          "bordercolor rgba(F40009AA) rgba(40009AA),floating:1"
          "suppressevent maximize, class:.*"
          "float,title:(Authentication Required)"
          "stayfocused,title:(Authentication Required)"
          "stayfocused,class:(ulauncher)"
        ];
      };
    };
  }

}
