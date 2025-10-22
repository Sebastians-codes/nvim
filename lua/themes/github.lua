local M = {
  setup = function()
    require('github-theme').setup {
      theme_style = 'dark_default',
      function_style = 'italic',
      sidebars = { 'qf', 'vista_kind', 'terminal', 'packer' },
      dark_sidebar = true,
      transparent = false,
    }
    vim.cmd [[colorscheme github_dark_default]]
  end
}

return M