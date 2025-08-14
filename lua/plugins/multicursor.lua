return {
  'mg979/vim-visual-multi',
  branch = 'master',
  config = function()
    -- Disable default mappings to avoid conflicts
    vim.g.VM_default_mappings = 0
    
    -- Custom mappings
    vim.g.VM_maps = {
      ['Find Under'] = '<C-n>',           -- Ctrl+n to select word under cursor
      ['Find Subword Under'] = '<C-n>',   -- Same for subwords
      ['Select Cursor Down'] = '<C-Down>', -- Ctrl+Down for cursor below
      ['Select Cursor Up'] = '<C-Up>',     -- Ctrl+Up for cursor above
      ['Skip Region'] = '<C-x>',          -- Ctrl+x to skip current selection
      ['Remove Region'] = '<C-q>',        -- Ctrl+q to remove current cursor
      ['Start Regex Search'] = '/',       -- Start regex search
      ['Visual Regex'] = '/',             -- Visual mode regex
      ['Visual All'] = '<leader>A',       -- Leader+A to select all matches
      ['Visual Add'] = '<leader>a',       -- Leader+a to add visual selection
      ['Case Setting'] = '<leader>c',     -- Leader+c to toggle case sensitivity
      ['Goto Next'] = '}',                -- Use } for next cursor
      ['Goto Prev'] = '{',                -- Use { for prev cursor
    }
    
    -- Settings for better case handling
    vim.g.VM_case_setting = 'ignore'     -- Always case-insensitive (preserves original case when editing)
    vim.g.VM_silent_exit = 1             -- Don't show message when exiting
    
    -- Custom highlighting
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        vim.api.nvim_set_hl(0, 'VM_Cursor', { bg = '#ff6b6b', fg = '#ffffff' })          -- Active cursor (red)
        vim.api.nvim_set_hl(0, 'VM_Extend', { bg = '#b3c8c8', fg = '#000000' })          -- Selected text
        vim.api.nvim_set_hl(0, 'VM_Insert', { bg = '#45b7d1', fg = '#ffffff' })          -- Insert mode (blue)
        vim.api.nvim_set_hl(0, 'VM_Mono', { bg = '#96ceb4', fg = '#000000' })            -- Mono cursor (green)
      end
    })
    
    -- Apply highlighting immediately
    vim.api.nvim_set_hl(0, 'VM_Cursor', { bg = '#ff6b6b', fg = '#ffffff' })
    vim.api.nvim_set_hl(0, 'VM_Extend', { bg = '#b3c8c8', fg = '#000000' })
    vim.api.nvim_set_hl(0, 'VM_Insert', { bg = '#45b7d1', fg = '#ffffff' })
    vim.api.nvim_set_hl(0, 'VM_Mono', { bg = '#96ceb4', fg = '#000000' })
  end,
}