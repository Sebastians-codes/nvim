-- LSP Rename with Telescope UI
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    -- Set up the keymap
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('telescope-rename-lsp-attach', { clear = true }),
      callback = function(event)
        vim.keymap.set('n', '<leader>rn', function()
          require('utils.rename').rename()
        end, {
          buffer = event.buf,
          desc = '[R]e[n]ame',
        })
      end,
    })
  end,
}
