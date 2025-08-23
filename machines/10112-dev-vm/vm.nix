{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    btop
    zsh
    oh-my-zsh
    fzf
    bat
    neofetch
    jq
    yq
    tree
    ipcalc
    nixd
  ];
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;


}
