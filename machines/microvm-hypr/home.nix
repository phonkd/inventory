{ config, pkgs, lib, ... }:

let
  # Read the base hyprland.conf and strip hardware-specific lines for VM
  baseConfig = builtins.readFile ../../modules/dotconfig/hypr/hyprland.conf;
  vmConfig = builtins.concatStringsSep "\n" (
    builtins.filter (line:
      # Remove hardware-specific settings that don't apply in a VM
      !(lib.hasPrefix "env = AQ_DRM_DEVICES" line) &&
      !(lib.hasPrefix "source = ~/.config/hypr/monitors.conf" line)
    ) (lib.splitString "\n" baseConfig)
  );
in
{
  imports = [
    ../../modules/home/common-home.nix
    ../../modules/home/linux-home.nix
  ];

  # Override Hyprland config for VM: strip hardware-specific lines, let defaults work
  wayland.windowManager.hyprland.extraConfig = lib.mkForce ''
    monitor=,preferred,auto,1

    ${vmConfig}
  '';

  home.packages = with pkgs; [
    waypipe
  ];
}
