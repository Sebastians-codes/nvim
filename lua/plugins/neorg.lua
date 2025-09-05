return {
  'nvim-neorg/neorg',
  lazy = false, -- Important: disable lazy loading
  version = '*', -- Pin to latest stable release
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {}, -- Loads default behavior
        ['core.concealer'] = {}, -- Adds pretty icons to your documents
        ['core.dirman'] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = '~/notes',
              work = '~/work-notes',
            },
            default_workspace = 'notes',
          },
        },
        ['core.completion'] = {
          config = {
            engine = 'nvim-cmp', -- We recommend using nvim-cmp
          },
        },
        ['core.integrations.nvim-cmp'] = {},
        ['core.keybinds'] = {
          config = {
            default_keybinds = true,
            neorg_leader = '<Leader>',
            hook = function(keybinds)
              -- Quick workspace switching
              keybinds.map('n', '<leader>tn', '<cmd>cd ~/notes<cr><cmd>Neorg workspace notes<cr><cmd>Neorg index<cr>', { desc = 'Switch to Notes workspace' })
              keybinds.map('n', '<leader>tw', '<cmd>cd ~/work-notes<cr><cmd>Neorg workspace work<cr><cmd>Neorg index<cr>', { desc = 'Switch to Work workspace' })
            end,
          },
        },
      },
    }

    -- Auto-sync notes to git on Neovim exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        -- Only sync if we have .norg files open
        local has_norg = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("%.norg$") then
              has_norg = true
              break
            end
          end
        end
        
        if has_norg then
          -- Sync notes repo
          vim.fn.system("cd ~/notes && git add . && git commit -m 'Auto-sync: " .. os.date("%Y-%m-%d %H:%M") .. "' && git push")
          -- Sync work-notes repo  
          vim.fn.system("cd ~/work-notes && git add . && git commit -m 'Auto-sync: " .. os.date("%Y-%m-%d %H:%M") .. "' && git push")
        end
      end,
    })
  end,
}