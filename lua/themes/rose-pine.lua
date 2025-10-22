local M = {
  setup = function()
    vim.cmd 'highlight clear'
    if vim.fn.exists 'syntax_on' then
      vim.cmd 'syntax reset'
    end

    vim.o.termguicolors = true
    vim.g.colors_name = 'rose-pine'

    require('rose-pine').setup {
      variant = 'auto',
      dark_variant = 'main',
      bold_vert_split = false,
      dim_nc_background = false,
      disable_background = false,
      disable_float_background = false,
      disable_italics = false,
      groups = {
        background = 'base',
        background_nc = '_experimental_nc',
        panel = 'surface',
        panel_nc = 'base',
        border = 'highlight_med',
        comment = 'muted',
        link = 'iris',
        punctuation = 'subtle',
        error = 'love',
        hint = 'iris',
        info = 'foam',
        warn = 'gold',
        headings = {
          h1 = 'iris',
          h2 = 'foam',
          h3 = 'rose',
          h4 = 'gold',
          h5 = 'pine',
          h6 = 'foam',
        },
      },
      highlight_groups = {},
    }

    vim.cmd 'colorscheme rose-pine'
  end,
}

return M

