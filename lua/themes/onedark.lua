local M = {
  setup = function()
    require('onedark').setup {}
    vim.cmd [[colorscheme onedark]]
  end,
}

return M
