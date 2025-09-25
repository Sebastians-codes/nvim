return {
  -- Better TypeScript support
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      settings = {
        tsserver_file_preferences = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },

  -- Auto-close JSX tags
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false -- Auto close on trailing </
        },
      })
    end,
  },

  -- Surround text objects (change/delete/add surrounding chars)
  {
    'kylechui/nvim-surround',
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  -- Emmet for HTML/JSX expansion
  {
    'mattn/emmet-vim',
    ft = { 'html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'jsx', 'tsx' },
    init = function()
      vim.g.user_emmet_leader_key = '<C-z>'
      vim.g.user_emmet_settings = {
        javascript = {
          extends = 'jsx',
        },
        typescript = {
          extends = 'tsx',
        },
      }
    end,
  },

  -- Package.json version info
  {
    'vuki656/package-info.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    opts = {
      highlights = {
        up_to_date = { fg = "#3C4048" },
        outdated = { fg = "#fc514e" },
      },
      package_manager = "npm", -- npm, yarn, pnpm
      hide_up_to_date = false,
      hide_unstable_versions = false,
    },
    config = function(_, opts)
      require('package-info').setup(opts)
      
      -- Set keymaps (using leader+p for package)
      vim.keymap.set('n', '<leader>ps', require('package-info').show, { desc = 'Show package versions' })
      vim.keymap.set('n', '<leader>ph', require('package-info').hide, { desc = 'Hide package versions' })
      vim.keymap.set('n', '<leader>pu', require('package-info').update, { desc = 'Update package on line' })
      vim.keymap.set('n', '<leader>pd', require('package-info').delete, { desc = 'Delete package on line' })
    end,
  },
}
