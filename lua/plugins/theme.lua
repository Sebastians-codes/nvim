return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require('kanagawa').setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = {},
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = true,
        dimInactive = false,
        terminalColors = true,
        colors = {
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} }
        },
        overrides = function(colors)
          return {
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          Pmenu = { bg = "NONE" },
          PmenuSbar = { bg = "NONE" },
          PmenuThumb = { bg = "NONE" },
          TelescopeNormal = { bg = "NONE" },
          TelescopeBorder = { bg = "NONE" },
          TelescopePromptNormal = { bg = "NONE" },
          TelescopePromptBorder = { bg = "NONE" },
          TelescopeResultsNormal = { bg = "NONE" },
          TelescopeResultsBorder = { bg = "NONE" },
          TelescopePreviewNormal = { bg = "NONE" },
          TelescopePreviewBorder = { bg = "NONE" },
          WhichKeyFloat = { bg = "NONE" },
          WhichKeyBorder = { bg = "NONE" },
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
          TabLine = { bg = "NONE" },
          TabLineFill = { bg = "NONE" },
          CursorLine = { bg = "NONE" },
          CursorLineNr = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          FoldColumn = { bg = "NONE" },
          WinBar = { bg = "NONE" },
          WinBarNC = { bg = "NONE" },
          MiniStatuslineModeNormal = { bg = "NONE", fg = colors.theme.ui.fg_dim, bold = true },
          MiniStatuslineModeInsert = { bg = "NONE", fg = colors.palette.springGreen, bold = true },
          MiniStatuslineModeVisual = { bg = "NONE", fg = colors.palette.oniViolet, bold = true },
          MiniStatuslineModeReplace = { bg = "NONE", fg = colors.palette.peachRed, bold = true },
          MiniStatuslineModeCommand = { bg = "NONE", fg = colors.palette.crystalBlue, bold = true },
          MiniStatuslineModeOther = { bg = "NONE", fg = colors.palette.fujiWhite, bold = true },
          MiniStatuslineDevinfo = { bg = "NONE" },
          MiniStatuslineFilename = { bg = "NONE" },
          MiniStatuslineFileinfo = { bg = "NONE" },
          MiniStatuslineInactive = { bg = "NONE" },
          LineNr = { bg = "NONE" },
          LineNrAbove = { bg = "NONE" },
          LineNrBelow = { bg = "NONE" },
          GitSignsAdd = { bg = "NONE" },
          GitSignsChange = { bg = "NONE" },
          GitSignsDelete = { bg = "NONE" },
          GitSignsAddNr = { bg = "NONE" },
          GitSignsChangeNr = { bg = "NONE" },
          GitSignsDeleteNr = { bg = "NONE" },
          GitSignsAddLn = { bg = "NONE" },
          GitSignsChangeLn = { bg = "NONE" },
          GitSignsDeleteLn = { bg = "NONE" },
          DiagnosticSignError = { fg = colors.theme.ui.fg_dim, bg = "NONE" },
          DiagnosticSignWarn = { fg = colors.theme.ui.fg_dim, bg = "NONE" },
          DiagnosticSignInfo = { fg = colors.theme.ui.fg_dim, bg = "NONE" },
          DiagnosticSignHint = { fg = colors.theme.ui.fg_dim, bg = "NONE" },
          CursorLineNr = { fg = colors.theme.ui.fg_dim, bg = "NONE" }, -- Muted line number
          MatchParen = { fg = colors.theme.ui.fg, bg = "NONE", bold = true }, -- White matching brackets
          }
        end,
        theme = "dragon",
        background = {
          dark = "dragon",
          light = "lotus"
        },
      })

      vim.cmd("colorscheme kanagawa")
    end,
  },
}