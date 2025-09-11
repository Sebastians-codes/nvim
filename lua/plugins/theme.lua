return {
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      require("nightfox").setup({
        palettes = {
          nordfox = {
            red = { base = "#a1828a", bright = "#b6969e", dim = "#8f7075" },
            orange = { base = "#b08a7e", bright = "#c19d93", dim = "#9c7269" },
            yellow = { base = "#c7b199", bright = "#d5c3aa", dim = "#b69d7c" },
            green = { base = "#98a893", bright = "#a8b8a5", dim = "#829180" },
            cyan = { base = "#8aa8b8", bright = "#9bb8c8", dim = "#7690a3" },
            blue = { base = "#7e94a8", bright = "#8ca6bc", dim = "#6d7f95" },
            purple = { base = "#9e8ca0", bright = "#b1a3b5", dim = "#8a7688" },
            pink = { base = "#a18aa8", bright = "#b69dbc", dim = "#8f7695" },
          }
        },
        options = {
          compile_path = vim.fn.stdpath("cache") .. "/nightfox",
          compile_file_suffix = "_compiled",
          transparent = true,
          terminal_colors = true,
          dim_inactive = false,
          module_default = true,
          colorblind = {
            enable = false,
            simulate_only = false,
            severity = {
              protan = 0,
              deutan = 0,
              tritan = 0,
            },
          },
          styles = {
            comments = "italic",
            conditionals = "NONE",
            constants = "NONE",
            functions = "NONE",
            keywords = "NONE",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
          },
          inverse = {
            match_paren = false,
            visual = false,
            search = false,
          },
        }
      })

      vim.cmd("colorscheme nordfox")
      
      -- Make all backgrounds transparent immediately
      vim.cmd('highlight Normal guibg=NONE')
      vim.cmd('highlight NormalNC guibg=NONE')
      vim.cmd('highlight StatusLine guibg=NONE')
      vim.cmd('highlight StatusLineNC guibg=NONE')
      vim.cmd('highlight TabLine guibg=NONE')
      vim.cmd('highlight TabLineFill guibg=NONE')
      vim.cmd('highlight TabLineSel guibg=NONE')
      vim.cmd('highlight WinBar guibg=NONE')
      vim.cmd('highlight WinBarNC guibg=NONE')
      vim.cmd('highlight NormalFloat guibg=NONE')
      vim.cmd('highlight FloatBorder guibg=NONE')
      vim.cmd('highlight Pmenu guibg=NONE')
      vim.cmd('highlight PmenuSel guibg=NONE')
      vim.cmd('highlight PmenuSbar guibg=NONE')
      vim.cmd('highlight PmenuThumb guibg=NONE')
      vim.cmd('highlight VertSplit guibg=NONE')
      vim.cmd('highlight WinSeparator guibg=NONE')
      vim.cmd('highlight CmdLine guibg=NONE')
      vim.cmd('highlight CmdLineIcon guibg=NONE')
      vim.cmd('highlight MsgArea guibg=NONE')
      vim.cmd('highlight ModeMsg guibg=NONE')
      vim.cmd('highlight MoreMsg guibg=NONE')
      vim.cmd('highlight Question guibg=NONE')
      vim.cmd('highlight ErrorMsg guibg=NONE')
      vim.cmd('highlight WarningMsg guibg=NONE')
      vim.cmd('highlight MiniStatuslineModeNormal guibg=NONE')
      vim.cmd('highlight MiniStatuslineModeInsert guibg=NONE')
      vim.cmd('highlight MiniStatuslineModeVisual guibg=NONE')
      vim.cmd('highlight MiniStatuslineModeReplace guibg=NONE')
      vim.cmd('highlight MiniStatuslineModeCommand guibg=NONE')
      vim.cmd('highlight MiniStatuslineModeOther guibg=NONE')
      vim.cmd('highlight MiniStatuslineDevinfo guibg=NONE')
      vim.cmd('highlight MiniStatuslineFilename guibg=NONE')
      vim.cmd('highlight MiniStatuslineFileinfo guibg=NONE')
      vim.cmd('highlight MiniStatuslineInactive guibg=NONE')
    end,
  }
}