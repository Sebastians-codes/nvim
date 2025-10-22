local M = {
  setup = function()
    require('vscode').setup {
      style = 'dark',
      transparent = false,
      italic_comments = true,
      disable_nvimtree_bg = true,
    }
    vim.cmd [[colorscheme vscode]]
  end
}

return M