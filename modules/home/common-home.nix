{ config, pkgs, ... }:

{
  imports = [
    ./terminal.nix
    ./editors.nix
    ./browser.nix
    ./syncthing.nix
  ];
  home = {
    username = "phonkd";
    stateVersion = "25.05";
    enableNixpkgsReleaseCheck = false;
  };
  sops.age = {
    keyFile =
      if pkgs.stdenv.isDarwin then
        "/Users/phonkd/.config/sops/age/keys.txt"
      else
        "/home/phonkd/.config/sops/age/keys.txt";
  };
  news.display = "silent";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nicotine-plus
    localsend
  ];
  programs.git = {
    enable = true;
    settings.user = {
      email = "phonkd@phonkd.net";
      name = "Phonkd";
    };
    includes = [
      {
        condition = "hasconfig:remote.*.url:*github.com*/**";
        contents = {
          core.sshCommand = "ssh -i ~/.ssh/id_ed25519_priv";
        };
      }
    ];
  };
}
