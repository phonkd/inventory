{ config, pkgs, ... }:

{
  home = {
    username = "phonkd";
    stateVersion = "25.05";
    enableNixpkgsReleaseCheck = false;
  };

  news.display = "silent";

  programs.git = {
    enable = true;
    userName = "Elis";
    userEmail = "phonkd@phonkd.net";
  };

  programs.home-manager.enable = true;

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      theme = "Adventure";
      font-size = 16;
      confirm-close-surface = false;
      keybind = [ "super+enter=new_split:right" ];
    };
  };
  home.packages = with pkgs; [
    nil
    nicotine-plus
    localsend
    yaml-language-server
  ];
  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = ''
          require("catppuccin").setup({
            flavour = "mocha"
          })
          vim.cmd([[colorscheme catppuccin]])
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', 'ff', builtin.find_files, {})
          vim.keymap.set('n', 'fg', builtin.live_grep, {})
          vim.keymap.set('n', 'fb', builtin.buffers, {})
          vim.keymap.set('n', 'fh', builtin.help_tags, {})
        '';
      }
      plenary-nvim # telescope dependency
    ];
  };

}
