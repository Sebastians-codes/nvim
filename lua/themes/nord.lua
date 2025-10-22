local M = {
  setup = function()
    vim.g.nord_borders = true
    vim.cmd [[colorscheme nord]]
  end,
}

return M
