{ config, pkgs, ... }:

{
  # List packages installed in system profile
  environment.systemPackages = [
    pkgs.vim
    pkgs.devbox
  ];

  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";

  # Used for backwards compatibility
  system.stateVersion = 6;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Auto upgrade nix package and the daemon service
  # services.nix-daemon.enable = true;

  # Create /etc/zshrc that loads the nix-darwin environment
  # programs.zsh.enable = true;

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  # # Clear Downloads and ~/tmp folders on boot
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
