local M = {
  setup = function()
    vim.g.nightflyCursorColor = 1
    vim.g.nightflyItalics = 1
    vim.g.nightflyNormalFloat = 1
    vim.g.nightflyTerminalColors = 1
    vim.g.nightflyTransparent = 0
    vim.g.nightflyUndercurls = 1
    vim.g.nightflyUnderlineMatchParen = 1
    vim.g.nightflyVirtualTextColor = 1
    vim.cmd [[colorscheme nightfly]]
  end,
}

return M

