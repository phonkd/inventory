{ config, pkgs, ... }:

{
  imports = [
    ../common-home.nix
  ];

  home.sessionVariables = {
    # EDITOR = "emacs";
    GSK_RENDERER = "gl";
    GDK_GL = "gles";
    SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  };

  home.packages = with pkgs; [
    waybar-lyric
  ];

  xdg.configFile."hypr/monitors.conf".text = ''
    monitor=,preferred,auto,1
  '';

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}