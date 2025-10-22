local M = {
  setup = function()
    require('catppuccin').setup {
      flavour = 'frappe',
    }
    vim.cmd [[colorscheme catppuccin]]
  end,
}

return M

