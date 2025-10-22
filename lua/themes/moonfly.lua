local M = {
  setup = function()
    vim.g.moonflyCursorColor = 1
    vim.g.moonflyItalics = 1
    vim.g.moonflyNormalFloat = 1
    vim.g.moonflyTerminalColors = 1
    vim.g.moonflyTransparent = 0
    vim.g.moonflyUndercurls = 1
    vim.g.moonflyUnderlineMatchParen = 1
    vim.g.moonflyVirtualTextColor = 1
    vim.cmd [[colorscheme moonfly]]
  end
}

return M