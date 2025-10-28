-- LSP Rename with Telescope UI
local M = {}

local function telescope_input(prompt_title, default_value, callback)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local input_entries = {
    {
      display = default_value and ('Current: ' .. default_value) or 'Type and press Enter...',
      value = 'input_prompt',
      ordinal = 'input_prompt',
    },
  }

  pickers
    .new(
      require('telescope.themes').get_dropdown {
        layout_config = {
          width = 0.5,
          height = 0.2,
        },
      },
      {
        prompt_title = prompt_title,
        default_text = default_value or '',
        finder = finders.new_table {
          results = input_entries,
          entry_maker = function(entry)
            return {
              value = entry.value,
              display = entry.display,
              ordinal = entry.ordinal,
            }
          end,
        },
        sorter = conf.generic_sorter {},
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local prompt_text = action_state.get_current_line()
            pcall(actions.close, prompt_bufnr)

            if prompt_text and prompt_text ~= '' then
              callback(prompt_text)
            elseif default_value then
              callback(default_value)
            else
              callback(nil)
            end
          end)

          return true
        end,
      }
    )
    :find()
end

function M.rename()
  -- Get current word under cursor
  local current_word = vim.fn.expand '<cword>'

  telescope_input('Rename: ' .. current_word, current_word, function(new_name)
    if new_name and new_name ~= '' and new_name ~= current_word then
      vim.lsp.buf.rename(new_name)
    end
  end)
end

return M
