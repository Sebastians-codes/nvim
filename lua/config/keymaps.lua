-- Keymaps
local session_manager = require 'config.session_manager'
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>silent w<CR>', { desc = 'Save File' })
local function open_parent_directory()
  require('config.oil').open_with_preview()
end
vim.keymap.set('n', '<leader>pv', open_parent_directory, { desc = 'Open parent directory' })
local function open_parent_directory_in_new_tab()
  vim.cmd 'tabnew'
  open_parent_directory()
end
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>qq', vim.diagnostic.setloclist, { desc = 'Diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>qe', function()
  vim.diagnostic.open_float {
    border = 'single',
  }
end, { desc = 'Show diagnostic [E]rror' })
vim.keymap.set('n', '<leader>qa', '<cmd>Telescope diagnostics<cr>', { desc = 'All diagnostics' })
vim.keymap.set('n', '<leader>qr', function()
  require('config.project-diagnostics').run_project_check()
end, { desc = 'Project-wide diagnostics' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Tab management
vim.keymap.set('n', 'tn', open_parent_directory_in_new_tab, { desc = 'New tab with parent directory' })
vim.keymap.set('n', 'tx', '<cmd>tabclose<CR>', { desc = 'Close tab' })
vim.keymap.set('n', 'tt', function()
  vim.cmd 'tabnew'
  vim.cmd 'terminal'
end, { desc = 'New tab with terminal' })
for i = 1, 9 do
  local idx = i
  vim.keymap.set('n', 't' .. idx, function()
    vim.cmd(string.format('tabnext %d', idx))
  end, { desc = 'Go to tab ' .. idx })
end

-- Session slots
vim.keymap.set('n', 'ss', session_manager.manage_slots, { desc = 'Manage session slots' })
vim.keymap.set('n', 'se', session_manager.assign_slot, { desc = 'Assign session slot' })
vim.keymap.set('n', '<leader>qs', session_manager.save_and_quit, { desc = 'Save session and quit Neovim' })
vim.keymap.set('n', 'sq', session_manager.save_and_quit, { desc = 'Save session and quit Neovim' })
for _, key in ipairs { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' } do
  local slot = key
  local label = slot == '0' and '10' or slot
  vim.keymap.set('n', 's' .. slot, function()
    session_manager.load_slot(slot)
  end, { desc = 'Load session slot ' .. label })
end

-- Auto-close brackets
vim.keymap.set('i', '(', '()<Left>')
vim.keymap.set('i', '[', '[]<Left>')
vim.keymap.set('i', '{', '{}<Left>')
vim.keymap.set('i', '"', '""<Left>')
vim.keymap.set('i', "'", "''<Left>")

-- Smart enter for brackets
vim.keymap.set('i', '<CR>', function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(col, col)
  local after = line:sub(col + 1, col + 1)

  if (before == '{' and after == '}') or (before == '[' and after == ']') or (before == '(' and after == ')') then
    return '<CR><CR><Up><Tab>'
  else
    return '<CR>'
  end
end, { expr = true })

-- Move lines up/down with Alt+J/K
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Comment/uncomment lines with <leader>cc
vim.keymap.set('n', '<leader>cc', function()
  require('Comment.api').toggle.linewise.current()
end, { desc = 'Comment line' })
vim.keymap.set('v', '<leader>cc', function()
  local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  require('Comment.api').toggle.linewise(vim.fn.visualmode())
end, { desc = 'Comment selection' })

-- Custom Shift+K with border
vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover {
    border = 'single',
  }
end, { desc = 'LSP Hover with border' })

-- New file and directory creation
vim.keymap.set('n', '<leader>nf', function()
  local current_dir = vim.fn.expand '%:p:h'
  if current_dir == '' then
    current_dir = vim.fn.getcwd()
  end

  vim.ui.input({
    prompt = 'New file name: ',
    default = current_dir .. '/',
    completion = 'file',
  }, function(input)
    if input then
      local file_path = input
      -- If it's not an absolute path, make it relative to current file's directory
      if not vim.startswith(file_path, '/') then
        file_path = current_dir .. '/' .. file_path
      end

      -- Create parent directories if they don't exist
      local parent_dir = vim.fn.fnamemodify(file_path, ':h')
      vim.fn.mkdir(parent_dir, 'p')

      -- Create and open the file
      vim.cmd('edit ' .. vim.fn.fnameescape(file_path))

      -- Force LSP attachment for the new file
      vim.schedule(function()
        vim.cmd 'doautocmd BufRead'
        -- Force Svelte LSP to attach to new .svelte files
        if file_path:match '%.svelte$' then
          vim.schedule(function()
            local bufnr = vim.api.nvim_get_current_buf()
            vim.lsp.start({
              name = 'svelte',
              cmd = { 'svelteserver', '--stdio' },
              root_dir = vim.fs.dirname(vim.fs.find({ 'package.json', '.git' }, { upward = true })[1]),
            }, { bufnr = bufnr })
          end)
        end
      end)
    end
  end)
end, { desc = 'New File' })

vim.keymap.set('n', '<leader>nd', function()
  local current_dir = vim.fn.expand '%:p:h'
  if current_dir == '' then
    current_dir = vim.fn.getcwd()
  end

  vim.ui.input({
    prompt = 'New directory name: ',
    default = current_dir .. '/',
    completion = 'dir',
  }, function(input)
    if input then
      local dir_path = input
      -- If it's not an absolute path, make it relative to current file's directory
      if not vim.startswith(dir_path, '/') then
        dir_path = current_dir .. '/' .. dir_path
      end

      -- Create the directory
      local success = vim.fn.mkdir(dir_path, 'p')
      if success == 1 then
        print('Created directory: ' .. dir_path)
      else
        print('Failed to create directory: ' .. dir_path)
      end
    end
  end)
end, { desc = 'New Directory' })

-- Super+\ to type ampersand
vim.keymap.set({ 'n', 'i', 'v' }, '<D-\\>', '&', { desc = 'Type ampersand' })

-- Theme picker
vim.keymap.set('n', '<leader>tt', function()
  require('themes.manager').show_theme_picker()
end, { desc = 'Theme picker' })
