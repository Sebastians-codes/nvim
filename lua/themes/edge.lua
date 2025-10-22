local M = {
  setup = function()
    vim.g.edge_style = 'default'
    vim.g.edge_enable_italic = 1
    vim.g.edge_transparent_background = 0
    vim.cmd [[colorscheme edge]]
  end
}

return M