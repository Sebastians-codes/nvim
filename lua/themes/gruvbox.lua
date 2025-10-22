local M = {
  setup = function()
    require('gruvbox').setup {}
    vim.cmd [[colorscheme gruvbox]]
  end
}

return M
