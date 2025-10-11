return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        dark_variant = "moon",
        bold_vert_split = false,
        dim_nc_background = false,
        disable_background = true,
        disable_float_background = true,
        disable_italics = false,
      })
      vim.cmd("colorscheme rose-pine")

      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "StatusLine",
        "StatusLineNC",
        "StatusLineTerm",
        "StatusLineTermNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "WinBar",
        "WinBarNC",
        "Pmenu",
        "PmenuSel",
        "PmenuSbar",
        "PmenuThumb",
        "VertSplit",
        "WinSeparator",
        "CmdLine",
        "CmdLineIcon",
        "MsgArea",
        "ModeMsg",
        "MoreMsg",
        "Question",
        "ErrorMsg",
        "WarningMsg",
        "MiniStatuslineModeNormal",
        "MiniStatuslineModeInsert",
        "MiniStatuslineModeVisual",
        "MiniStatuslineModeReplace",
        "MiniStatuslineModeCommand",
        "MiniStatuslineModeOther",
        "MiniStatuslineDevinfo",
        "MiniStatuslineFilename",
        "MiniStatuslineFileinfo",
        "MiniStatuslineInactive",
        "CursorLine",
      }

      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
      end
      vim.opt.cursorline = false
    end,
  },
}
