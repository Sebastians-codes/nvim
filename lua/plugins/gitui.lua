return {
  'mason-org/mason.nvim',
  opts = { ensure_installed = { 'gitui' } },
  keys = {
    {
      '<leader>gG',
      function()
        Snacks.terminal({ 'gitui' }, { win = { border = 'single' } })
      end,
      desc = 'GitUi (cwd)',
    },
    {
      '<leader>gg',
      function()
        Snacks.terminal({ 'gitui' }, { cwd = vim.fn.getcwd(), win = { border = 'single' } })
      end,
      desc = 'GitUi (Root Dir)',
    },
  },
}
