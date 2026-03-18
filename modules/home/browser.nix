{ config, pkgs, ... }:

{
  home.file.".librewolf/.stignore".text = ''
    // Session & auth tokens
    cookies.sqlite
    cookies.sqlite-wal
    cookies.sqlite-shm

    // Lock files (machine-specific)
    lock
    .parentlock

    // Caches
    cache2
    startupCache
    shader-cache
    thumbnails

    // Crash/telemetry data
    crashes
    minidumps
    datareporting
    saved-telemetry-pings

    // Machine-specific state
    security_state
    safebrowsing
    sessionstore-backups

    // Bitwarden extension data
    browser-extension-data/{446900e4-71c2-419f-a6a7-df9c091e268b}
    storage/default/moz-extension+++*
  '';
  programs.librewolf = {
    enable = true;
  };
  services.syncthing.settings = {
    folders."browser-profiles" = {
      path = if pkgs.stdenv.isDarwin then "/Users/phonkd/browser-profiles" else "~/.librewolf";
      ignorePerms = false;
    };
  };
}
