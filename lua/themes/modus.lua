local M = {
  setup = function()
    require('modus-themes').setup {
      style = 'modus_operandi',
      variant = 'default',
      transparent = false,
      dim_inactive = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
      on_colors = function(colors) end,
      on_highlights = function(highlights, colors) end,
    }
    vim.cmd [[colorscheme modus]]
  end
}

return M