return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-y>",
            accept_word = false,
            accept_line = false,
            next = "<C-]>",
            prev = "<C-[>",
            dismiss = "<C-e>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
      })
      
      -- Disable copilot on startup (silently)
      vim.schedule(function()
        vim.cmd('silent! Copilot disable')
      end)
      
      -- Fix Esc to dismiss Copilot suggestion and exit insert mode
      vim.keymap.set('i', '<Esc>', function()
        if require("copilot.suggestion").is_visible() then
          require("copilot.suggestion").dismiss()
        end
        return '<Esc>'
      end, { expr = true, desc = 'Dismiss Copilot and exit insert mode' })
      
      -- Toggle Copilot on/off
      local copilot_enabled = false
      vim.keymap.set('n', '<leader>cp', function()
        if copilot_enabled then
          vim.cmd('silent! Copilot disable')
          copilot_enabled = false
        else
          vim.cmd('silent! Copilot enable')
          copilot_enabled = true
        end
      end, { desc = 'Toggle Copilot' })
    end,
  },
}