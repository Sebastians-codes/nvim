-- File and Directory Management with Telescope UI
local M = {}

local function telescope_input(prompt_title, default_value, callback)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local input_entries = {
    {
      display = default_value and ('Default: ' .. default_value) or 'Type and press Enter...',
      value = 'input_prompt',
      ordinal = 'input_prompt',
    },
  }

  pickers
    .new(
      require('telescope.themes').get_dropdown {
        layout_config = {
          width = 0.6,
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

function M.new_file()
  local current_dir = vim.fn.expand '%:p:h'
  if current_dir == '' then
    current_dir = vim.fn.getcwd()
  end

  telescope_input('New File Name', current_dir .. '/', function(input)
    if not input then
      return
    end

    local file_path = input
    -- If it's not an absolute path, make it relative to current file's directory
    if not vim.startswith(file_path, '/') then
      file_path = current_dir .. '/' .. file_path
    end

    -- Create parent directories if they don't exist
    local parent_dir = vim.fn.fnamemodify(file_path, ':h')
    vim.fn.mkdir(parent_dir, 'p')

    -- Create and open the file
    vim.cmd('edit ' .. vim.fn.fnameescape(file_path))

    -- Force LSP attachment for the new file
    vim.schedule(function()
      vim.cmd 'doautocmd BufRead'
      -- Force Svelte LSP to attach to new .svelte files
      if file_path:match '%.svelte$' then
        vim.schedule(function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.lsp.start({
            name = 'svelte',
            cmd = { 'svelteserver', '--stdio' },
            root_dir = vim.fs.dirname(vim.fs.find({ 'package.json', '.git' }, { upward = true })[1]),
          }, { bufnr = bufnr })
        end)
      end
    end)
  end)
end

function M.new_directory()
  local current_dir = vim.fn.expand '%:p:h'
  if current_dir == '' then
    current_dir = vim.fn.getcwd()
  end

  telescope_input('New Directory Name', current_dir .. '/', function(input)
    if not input then
      return
    end

    local dir_path = input
    -- If it's not an absolute path, make it relative to current file's directory
    if not vim.startswith(dir_path, '/') then
      dir_path = current_dir .. '/' .. dir_path
    end

    -- Create the directory
    local success = vim.fn.mkdir(dir_path, 'p')
    if success == 1 then
      vim.notify('Created directory: ' .. dir_path, vim.log.levels.INFO)
    else
      vim.notify('Failed to create directory: ' .. dir_path, vim.log.levels.ERROR)
    end
  end)
end

return M
