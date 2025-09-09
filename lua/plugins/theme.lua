return {
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      require("nightfox").setup({
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