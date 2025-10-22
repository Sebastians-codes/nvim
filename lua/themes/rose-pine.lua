local M = {
  setup = function()
    require('rose-pine').setup {}
    vim.cmd [[colorscheme rose-pine]]
  end
}

return M
