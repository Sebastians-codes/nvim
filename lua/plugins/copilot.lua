return {
  'github/copilot.vim',
  lazy = false,
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true

    vim.keymap.set('i', '<M-l>', 'copilot#Accept("")', { expr = true, replace_keycodes = false })
    vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)')
    vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)')
    vim.keymap.set('i', '<C-]>', '<Plug>(copilot-dismiss)')

    vim.keymap.set('n', '<leader>ct', function()
      if vim.g.copilot_enabled == 0 then
        vim.cmd 'Copilot enable'
      else
        vim.cmd 'Copilot disable'
      end
    end, { desc = 'Toggle Copilot' })
  end,
}
