local M = {
  setup = function()
    require('tokyonight').setup {
      style = 'night',
    }
    vim.cmd [[colorscheme tokyonight]]
  end
}

return M