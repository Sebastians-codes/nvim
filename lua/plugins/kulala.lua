-- REST client integration
return {
  'mistweaverco/kulala.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ft = { 'http', 'rest' },
  keys = {
    {
      '<leader>es',
      function()
        require('kulala').run()
      end,
      mode = { 'n', 'v' },
      desc = 'Kulala: send request',
    },
    {
      '<leader>ea',
      function()
        require('kulala').run_all()
      end,
      mode = { 'n', 'v' },
      desc = 'Kulala: send all requests',
    },
    {
      '<leader>eb',
      function()
        require('kulala').scratchpad()
      end,
      desc = 'Kulala: open scratchpad',
    },
    {
      '<leader>ee',
      function()
        require('kulala').open()
      end,
      desc = 'Kulala: open UI',
    },
  },
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = '<leader>e',
    kulala_keymaps_prefix = '',
    ui = {
      display_mode = 'float',
      win_opts = {
        border = 'rounded',
      },
      default_view = 'body',
    },
  },
  config = function(_, opts)
    require('kulala').setup(opts)
  end,
}
