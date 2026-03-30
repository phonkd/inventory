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
    stateVersion = "26.05";
    enableNixpkgsReleaseCheck = true;
  };
  xdg.enable = true;
  #news.display = "silent";
  programs.nix-index.enableZshIntegration = true;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nicotine-plus
    localsend
    (discord.override {
      #withOpenASAR = true;
      withVencord = true; # can do this here too
    })
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "phonkd@phonkd.net";
        name = "Phonkd";
      };
      pull.rebase = true;
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
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "homelab" = {
        host = "192.168.1.*";
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
      };
      "github" = {
        host = "github.com";
        identityFile = "~/.ssh/id_ed25519_priv";
        identitiesOnly = true;
      };
    };
  };
}
