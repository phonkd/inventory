{
  config,
  pkgs,
  lib,
  ...
}:

{
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    devbox
    kconf
    nix-search-tv
  ];
  imports = [
    ./builder.nix
    ../../modules/dns-darwin.nix
    #../../modules/secret-fix.nix
  ];
  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };
  system.defaults = {
    NSGlobalDomain = {
      NSWindowShouldDragOnGesture = true;
      NSAutomaticQuoteSubstitutionEnabled = false;
    };
  };
  system.primaryUser = "phonkd";

  users.users.phonkd.home = "/Users/phonkd";
}
