local M = {
  setup = function()
    require('nightfox').setup {}
    vim.cmd [[colorscheme nightfox]]
  end,
}

return M
