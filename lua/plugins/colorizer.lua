return {
  {
    'uga-rosa/ccc.nvim',
    config = function()
      require('ccc').setup {
        -- Your preferred settings
        highlighter = {
          auto_enable = true,
          lsp = true,
        },
        -- Enable for these file types
        filetypes = {
          'css',
          'scss',
          'sass',
          'less',
          'html',
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
          'vue',
          'svelte',
        },
      }

      -- Set up keymaps
      vim.keymap.set('n', '<leader>kp', '<cmd>CccPick<cr>', { desc = 'Color Picker' })
      vim.keymap.set('n', '<leader>kc', '<cmd>CccConvert<cr>', { desc = 'Convert Color Format' })
      vim.keymap.set('n', '<leader>kt', '<cmd>CccHighlighterToggle<cr>', { desc = 'Toggle Color Highlighting' })
    end,
  },
}

