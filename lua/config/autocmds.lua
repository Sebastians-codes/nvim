-- Autocommands

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Set indentation for specific languages
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cs', 'go', 'rust' },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

-- Ensure proper filetype detection for React files
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.tsx' },
  callback = function()
    vim.bo.filetype = 'typescriptreact'
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.jsx' },
  callback = function()
    vim.bo.filetype = 'javascriptreact'
  end,
})