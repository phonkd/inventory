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
  home.stateVersion = "24.05"; # Please read the comment before changing.
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


  xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
}
