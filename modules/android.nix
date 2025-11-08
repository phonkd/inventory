# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.adb.enable = true;
  environment.systemPackages = with pkgs; [
    payload-dumper-go
    unzip
    peazip
    file
    zip
    clang
    llvm
    lld
    gnirehtet
    # Cross compilers
    gcc-arm-embedded # for arm-linux-gnueabihf-
    libgcc # for aarch64-linux-gnu-

    # Kernel build dependencies
    bc
    bison
    flex
    perl
    openssl
    elfutils
    xz
    lzop
    rsync
    ncurses
    python3
    git
    gnumake
    util-linux
    pkg-config
    distrobox
    distrobox-tui
    heimdall
    heimdall-gui
    android-studio
    sdkmanager
  ];
  #virtualisation.waydroid.enable = true;
  # programs.zsh = {
  #
  programs.zsh = {
    shellAliases = {
      android-ssh = "adb forward tcp:8022 tcp:8022 && ssh -luser -p 8022 localhost";
    };
  };
}
