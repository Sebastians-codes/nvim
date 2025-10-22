local M = {
  setup = function()
    vim.g.material_style = 'deep ocean'
    require('material').setup {
      contrast = {
        terminal = false,
        sidebars = false,
        floating_windows = false,
        cursor_line = false,
        non_current_windows = false,
        filetypes = {},
      },
      styles = {
        comments = { italic = true },
        strings = { bold = true },
        keywords = { underline = true },
        functions = { bold = true, undercurl = true },
        variables = {},
        operators = {},
        types = {},
      },
      plugins = {
        'dap',
        'dashboard',
        'gitsigns',
        'hop',
        'indent-blankline',
        'lspsaga',
        'mini',
        'neogit',
        'neorg',
        'nvim-cmp',
        'nvim-navic',
        'nvim-tree',
        'nvim-web-devicons',
        'sneak',
        'telescope',
        'trouble',
        'which-key',
      },
      disable = {
        colored_cursor = false,
        borders = false,
        background = false,
        term_colors = false,
        eob_lines = false,
      },
      high_visibility = {
        lighter = false,
        darker = false,
      },
      lualine_style = 'default',
      async_loading = true,
      custom_colors = nil,
      custom_highlights = {},
    }
    vim.cmd [[colorscheme material]]
  end
}

return M