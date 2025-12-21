{
  config,
  pkgs,
  lib,
  ...
}:
let
  isVM = lib.elem "vm" config.label.labels;
in
{
  imports = [
    #../machines-nok8s/apps/sops.nix
    ./teleport.nix
    ./sops.nix
    #(modulesPath + "/profiles/qemu-guest.nix")
  ];
  sops.age = lib.mkIf isVM {
    keyFile = "/home/phonkd/.config/sops/age/keys.txt";
  };
  sops.defaultSopsFile = ./global-secrets/secret.yaml;
  environment.systemPackages = [
    pkgs.git
    pkgs.killall
  ];
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };
  console.keyMap = "sg";
  users.groups.phonkd = { };
  users.users.phonkd = {
    isNormalUser = true;
    description = "phonkd";
    group = "phonkd";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    #password = "sml12345";
  };
  users.mutableUsers = true;
  security.sudo.wheelNeedsPassword = false;
  programs.git = {
    enable = true;
    config = {
      user.name = "Elis";
      user.email = "enst18.12@gmail.com";
    };
  };
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [
        "git"
        "kubectl"
        "fzf"
      ];
      theme = "robbyrussell";
    };
  };
  users.defaultUserShell = pkgs.zsh;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
