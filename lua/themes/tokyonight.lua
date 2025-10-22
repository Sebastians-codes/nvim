local M = {
  setup = function()
    require('tokyonight').setup {
      transparent = true,
      on_colors = function(c) end,
      on_highlights = function(hl, c) end,
      styles = {
        sidebars = 'transparent',
        floats = 'transparent',
      },
    }
    vim.cmd [[colorscheme tokyonight]]

    local hi = function(group, opts)
      vim.api.nvim_set_hl(0, group, opts)
    end

    hi('Normal', { bg = 'NONE' })
    hi('NormalFloat', { bg = 'NONE' })
    hi('SignColumn', { bg = 'NONE' })
    hi('LineNr', { bg = 'NONE' })
    hi('CursorLineNr', { bg = 'NONE' })
    hi('StatusLine', { bg = 'NONE' })
    hi('StatusLineNC', { bg = 'NONE' })
    hi('TabLine', { bg = 'NONE' })
    hi('TabLineFill', { bg = 'NONE' })
    hi('TabLineSel', { bg = 'NONE' })
    hi('ColorColumn', { bg = 'NONE' })
    hi('CursorLine', { bg = 'NONE' })
    hi('CursorColumn', { bg = 'NONE' })
    hi('Pmenu', { bg = 'NONE' })
    hi('PmenuSbar', { bg = 'NONE' })
    hi('Folded', { bg = 'NONE' })
    hi('FoldColumn', { bg = 'NONE' })
    hi('TelescopeNormal', { bg = 'NONE' })
    hi('TelescopeBorder', { bg = 'NONE' })
    hi('TelescopePromptNormal', { bg = 'NONE' })
    hi('TelescopePromptBorder', { bg = 'NONE' })
    hi('TelescopeResultsNormal', { bg = 'NONE' })
    hi('TelescopeResultsBorder', { bg = 'NONE' })
    hi('TelescopePreviewNormal', { bg = 'NONE' })
    hi('TelescopePreviewBorder', { bg = 'NONE' })
    hi('WhichKeyFloat', { bg = 'NONE' })
    hi('FloatBorder', { bg = 'NONE' })
    hi('WhichKeyNormal', { bg = 'NONE' })
    hi('WhichKeyBorder', { bg = 'NONE' })
    hi('MiniStatuslineModeReplace', { bg = 'NONE' })
    hi('MiniStatuslineModeCommand', { bg = 'NONE' })
    hi('MiniStatuslineModeOther', { bg = 'NONE' })
    hi('MiniStatuslineDevinfo', { bg = 'NONE' })
    hi('MiniStatuslineFilename', { bg = 'NONE' })
    hi('MiniStatuslineFileinfo', { bg = 'NONE' })
    hi('MiniStatuslineInactive', { bg = 'NONE' })
  end,
}

return M
