local M = {
  setup = function()
    require('tokyonight').setup {
      style = 'storm',
    }
    vim.cmd [[colorscheme tokyonight]]
  end
}

return M