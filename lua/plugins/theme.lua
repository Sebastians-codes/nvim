return {
  { 'bjarneo/nes.nvim', lazy = true },
  { 'folke/tokyonight.nvim', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  { 'Mofiqul/dracula.nvim', lazy = true },
  { 'sainnhe/everforest', lazy = true },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'nyoom-engineering/oxocarbon.nvim', lazy = true },
  { 'projekt0n/github-nvim-theme', lazy = true },
  { 'Mofiqul/vscode.nvim', lazy = true },
  { 'tanvirtin/monokai.nvim', lazy = true },
  { 'ishan9299/nvim-solarized-lua', lazy = true },
  { 'Shatur/neovim-ayu', lazy = true },
  { 'drewtempelmeyer/palenight.vim', lazy = true },
  { 'sainnhe/sonokai', lazy = true },
  { 'scottmckendry/cyberdream.nvim', lazy = true },
  { 'savq/melange', lazy = true },
  { 'miikanissi/modus-themes.nvim', lazy = true },
  { 'olivercederborg/poimandres.nvim', lazy = true },
  { 'rmehri01/onenord.nvim', lazy = true },
  { 'marko-cerovac/material.nvim', lazy = true },
  { 'bluz71/vim-nightfly-guicolors', lazy = true },
  { 'bluz71/vim-moonfly-colors', lazy = true },
  { 'sainnhe/edge', lazy = true },
  { 'sainnhe/gruvbox-material', lazy = true },
  { 'cocopon/iceberg.vim', lazy = true },
  { 'jacoborus/tender.vim', lazy = true },
  { 'sainnhe/edge', lazy = true },
  { 'shaunsingh/nord.nvim', lazy = true },
  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'navarasu/onedark.nvim', lazy = true },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },
  {
    name = 'theme-loader',
    dir = vim.fn.stdpath 'config',
    lazy = false,
    priority = 1000,
    config = function()
      local theme_manager = require 'themes.manager'
      local saved_theme = theme_manager.get_saved_theme()
      local transparent = theme_manager.get_transparency_state()
      theme_manager.transparency.enabled = transparent
      theme_manager.load_theme(saved_theme, true)
    end,
  },
}
