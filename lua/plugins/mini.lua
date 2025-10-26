return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()
    require('mini.sessions').setup {
      autoread = false,
      autowrite = true,
      directory = vim.fn.stdpath 'data' .. '/sessions',
    }

    -- Custom save message system
    local save_message = ''
    local save_timer = nil

    local function show_save_message(msg)
      save_message = msg
      if save_timer then
        vim.fn.timer_stop(save_timer)
      end
      save_timer = vim.fn.timer_start(3000, function()
        save_message = ''
        vim.cmd 'redrawstatus'
      end)
      vim.cmd 'redrawstatus'
    end

    local statusline = require 'mini.statusline'
    local function tab_section()
      local total_tabs = vim.fn.tabpagenr '$'
      if total_tabs <= 1 then
        return ''
      end

      local current_tab = vim.fn.tabpagenr()
      local labels = {}
      for tab = 1, total_tabs do
        if tab == current_tab then
          table.insert(labels, '[' .. tab .. ']')
        else
          table.insert(labels, tostring(tab))
        end
      end

      return 'Tabs ' .. table.concat(labels, ' ')
    end

    statusline.setup {
      use_icons = vim.g.have_nerd_font,
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
          local git = MiniStatusline.section_git { trunc_width = 40 }
          local diff = MiniStatusline.section_diff { trunc_width = 75 }
          local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
          local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
          local filename = save_message ~= '' and save_message or MiniStatusline.section_filename { trunc_width = 140 }
          local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
          local tabs = tab_section()
          local location = '%2l:%-2v'
          local search = MiniStatusline.section_searchcount { trunc_width = 75 }

          return MiniStatusline.combine_groups {
            { hl = mode_hl, strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
            '%<', -- Mark general truncate point
            { hl = save_message ~= '' and 'MiniStatuslineDevinfo' or 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo, tabs, location, search } },
          }
        end,
        inactive = function()
          local filename = MiniStatusline.section_filename { trunc_width = 140 }
          return MiniStatusline.combine_groups {
            { hl = 'MiniStatuslineFilename', strings = { filename } },
          }
        end,
      },
    }

    -- Override write commands to prevent default messages
    vim.api.nvim_create_user_command('W', function()
      vim.cmd 'silent write'
      show_save_message '✓ File saved'
    end, {})

    -- Hook into save events for :w commands
    vim.api.nvim_create_autocmd('BufWritePost', {
      callback = function()
        -- Small delay to let the default message appear and then override it
        vim.defer_fn(function()
          show_save_message '✓ File saved'
        end, 10)
      end,
    })

    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
}
