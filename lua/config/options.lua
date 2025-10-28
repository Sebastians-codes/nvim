-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Disable inline diagnostics (virtual text)
vim.diagnostic.config {
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = false
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Show statusline
vim.opt.laststatus = 2
-- Hide builtin tabline (tab info is shown in statusline)
vim.opt.showtabline = 0
-- Give command line enough space to display messages
vim.opt.cmdheight = 0
-- Reduce message verbosity to avoid flashing
vim.opt.shortmess = 'filnxtToOFWIcC' -- Suppress most messages including save info

-- Create command abbreviation to make :w silent
vim.cmd [[cnoreabbrev w silent w]]

 -- Set indentation for specific filetypes
 vim.api.nvim_create_autocmd('FileType', {
   pattern = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'html', 'css', 'svelte', 'c', 'rs' },
   callback = function()
     vim.opt_local.tabstop = 2
     vim.opt_local.shiftwidth = 2
     vim.opt_local.expandtab = true
   end,
 })

 -- Set 4 spaces for C# files
 vim.api.nvim_create_autocmd('FileType', {
   pattern = 'cs',
   callback = function()
     vim.opt_local.tabstop = 4
     vim.opt_local.shiftwidth = 4
     vim.opt_local.expandtab = true
   end,
 })
