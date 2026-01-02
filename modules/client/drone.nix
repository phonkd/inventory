# Auto-generated using compose2nix v0.3.
# 1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    #  nvidia-vaapi-driver
    betaflight-configurator
    wineWowPackages.waylandFull
  ];
}
