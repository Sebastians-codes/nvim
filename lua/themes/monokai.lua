local M = {
  setup = function()
    require('monokai').setup {}
    vim.cmd [[colorscheme monokai]]
  end
}

return M