local M = {
  setup = function()
    require('catppuccin').setup {
      flavour = 'macchiato',
    }
    vim.cmd [[colorscheme catppuccin]]
  end,
}

return M

