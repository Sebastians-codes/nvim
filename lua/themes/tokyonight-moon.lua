local M = {
  setup = function()
    require('tokyonight').setup {
      style = 'moon',
    }
    vim.cmd [[colorscheme tokyonight]]
  end
}

return M
