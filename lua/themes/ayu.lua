local M = {
  setup = function()
    require('ayu').setup {
      mirage = false,
      overrides = {},
    }
    vim.cmd [[colorscheme ayu-dark]]
  end
}

return M