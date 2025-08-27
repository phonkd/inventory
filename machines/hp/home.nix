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
  # wayland.windowManager.hyprland.enable = true; will probably never do this cuz lazy to convert config.
  # wayland.windowManager.hyprland.settings = {
  #   "$mod" = "SUPER";
  #   bind =
  #     [
  #       "$mod, W, exec, firefox"
  #       "$mod, SHIFT, 2, exec, grimblast copy area"
  #       "$mod, Q, "
  #     ]
  #     ++ (
  #       # workspaces
  #       # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
  #       builtins.concatLists (builtins.genList (i:
  #           let ws = i + 1;
  #           in [
  #             "$mod, code:1${toString i}, workspace, ${toString ws}"
  #             "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
  #           ]
  #         )
  #         9)
  #     );
  # };
}
