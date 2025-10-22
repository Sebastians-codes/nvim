return {
  { 'bjarneo/nes.nvim', lazy = true },
  { 'folke/tokyonight.nvim', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  { 'shaunsingh/nord.nvim', lazy = true },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },
  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'navarasu/onedark.nvim', lazy = true },
  {
    name = 'theme-loader',
    dir = vim.fn.stdpath 'config',
    lazy = false,
    priority = 1000,
    config = function()
      local theme_manager = require 'themes.manager'
      local saved_theme = theme_manager.get_saved_theme()
      theme_manager.load_theme(saved_theme, true)
    end,
  },
}
