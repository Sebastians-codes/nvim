local M = {
  setup = function()
    vim.g.everforest_background = 'hard'
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_transparent_background = 0
    vim.cmd [[colorscheme everforest]]
  end,
}

return M

