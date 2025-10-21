-- File operations plugin
return {
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    config = function()
      require('dressing').setup {
        input = {
          enabled = true,
          default_prompt = 'Input:',
          prompt_align = 'left',
          insert_only = true,
          start_in_insert = true,
          anchor = 'SW',
          border = 'rounded',
          relative = 'cursor',
          prefer_width = 40,
          width = nil,
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },
          buf_options = {},
          win_options = {
            winblend = 10,
            wrap = false,
          },
          mappings = {
            n = {
              ['<Esc>'] = 'Close',
              ['<CR>'] = 'Confirm',
            },
            i = {
              ['<C-c>'] = 'Close',
              ['<CR>'] = 'Confirm',
              ['<Up>'] = 'HistoryPrev',
              ['<Down>'] = 'HistoryNext',
            },
          },
        },
      }
    end,
  },
  {
    'stevearc/oil.nvim',
    cmd = 'Oil',
    dependencies = {
      {
        'nvim-tree/nvim-web-devicons',
        optional = true,
      },
    },
    keys = {
      {
        '-',
        function()
          require('config.oil').open_with_preview()
        end,
        desc = 'Open parent directory',
      },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 2,
        max_width = 90,
        max_height = 35,
      },
      keymaps = {
        ['<C-h>'] = false,
        ['<C-l>'] = false,
      },
    },
    init = function()
      if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
        require('lazy').load { plugins = { 'oil.nvim' } }
      end
    end,
    config = function(_, opts)
      local oil_config = require 'config.oil'
      oil_config.setup(opts)

      vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        callback = function()
          oil_config.handle_startup_directory()
        end,
      })
    end,
  },
}
