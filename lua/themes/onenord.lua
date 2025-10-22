local M = {
  setup = function()
    require('onenord').setup {
      theme = nil,
      borders = true,
      fade_nc = false,
      styles = {
        comments = 'italic',
        strings = 'NONE',
        keywords = 'NONE',
        functions = 'NONE',
        variables = 'NONE',
        diagnostics = 'underline',
      },
      disable = {
        background = false,
        float_background = false,
        cursorline = false,
        eob_lines = true,
      },
      custom_highlights = {},
      custom_colors = {},
    }
    vim.cmd [[colorscheme onenord]]
  end,
}

return M

