return {
  {
    'OXY2DEV/markview.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {},
    keys = {
      {
        '<leader>mp',
        '<cmd>Markview toggle<cr>',
        desc = 'Toggle Markdown Preview',
      },
    },
  },
}
