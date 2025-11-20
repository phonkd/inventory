{ config, pkgs, lib, ... }:

{
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    devbox
    kconf
  ];
  imports = [
    ./builder.nix
    #../../modules/secret-fix.nix
  ];
  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";

  # Used for backwards compatibility
  system.stateVersion = 6;
  # sops = {
  #   age = {
  #     sshKeyPaths = [];
  #     keyFile =
  #       if pkgs.stdenv.isDarwin then
  #         "/Users/phonkd/.config/sops/age/keys.txt"
  #       else
  #         "/home/phonkd/.config/sops/age/keys.txt";

  #   };
  #   gnupg.sshKeyPaths = [];
  # };

  # The platform the configuration will be used on
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
  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  # Set Git commit hash for darwin-version.
  # The platform the configuration will be used on.
  # launchd.daemons.cleanup-downloads = {
  #   command = "/bin/rm -rf /Users/*/Downloads/*";
  #   serviceConfig = {
  #     RunAtLoad = true;
  #     StandardOutPath = "/var/log/cleanup-downloads.log";
  #     StandardErrorPath = "/var/log/cleanup-downloads.log";
  #   };
  # };

  # launchd.daemons.cleanup-tmp = {
  #   command = "/bin/rm -rf /Users/Phonkd/tmp/*";
  #   serviceConfig = {
  #     RunAtLoad = true;
  #     StandardOutPath = "/var/log/cleanup-tmp.log";
  #     StandardErrorPath = "/var/log/cleanup-tmp.log";
  #   };
  # };
}
