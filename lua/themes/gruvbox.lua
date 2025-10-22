local M = {
  setup = function()
    require('gruvbox').setup {
      contrast = 'hard',
      transparent_mode = false,
    }
    vim.cmd [[colorscheme gruvbox]]
  end,
}

return M

