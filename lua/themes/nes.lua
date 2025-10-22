local M = {
  setup = function()
    vim.cmd [[colorscheme nes]]
    vim.g.nvim_tree_disable_default_colors = 1
    vim.g.nvim_web_devicons_set_default_icon = 1
  end,
}

return M
