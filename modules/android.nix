# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
{
  programs.adb.enable = true;
  environment.systemPackages = with pkgs; [
    payload-dumper-go
    unzip
    peazip
  ];
}
