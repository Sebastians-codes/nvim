local M = {
  setup = function()
    require('catppuccin').setup {
      flavour = 'latte',
    }
    vim.cmd [[colorscheme catppuccin]]
  end,
}

return M

