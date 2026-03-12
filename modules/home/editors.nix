{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nil
    nixd
    yaml-language-server
    claude-code
    sox
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
