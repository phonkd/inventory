{ pkgs, ... }:
{
  services.displayManager.sessionPackages = [
    (pkgs.runCommand "hyprland-session" {
      passthru.providedSessions = [ "hyprland" ];
    } ''
      mkdir -p $out/share/wayland-sessions
      cat <<EOF > $out/share/wayland-sessions/hyprland.desktop
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF
    '')
  ];
}