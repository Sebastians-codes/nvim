local M = {
  setup = function()
    require('dracula').setup {}
    vim.cmd [[colorscheme dracula]]
  end,
}

return M

