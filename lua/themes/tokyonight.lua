local M = {
  setup = function()
    require('tokyonight').setup {}
    vim.cmd [[colorscheme tokyonight]]
  end,
}

return M
