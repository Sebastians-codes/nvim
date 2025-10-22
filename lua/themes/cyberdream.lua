local M = {
  setup = function()
    require('cyberdream').setup {
      transparent = false,
      italic_comments = true,
      hide_fillchars = false,
      borderless_telescope = true,
      terminal_colors = true,
    }
    vim.cmd [[colorscheme cyberdream]]
  end,
}

return M

