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

-- .NET file templates
local dotnet_templates = {
  { name = 'Class', template = 'class', icon = '📦' },
  { name = 'Interface', template = 'interface', icon = '🔌' },
  { name = 'Record', template = 'record', icon = '📋' },
  { name = 'Enum', template = 'enum', icon = '🔢' },
  { name = 'Blank C# File', template = 'blank', icon = '📄' },
}

local function get_namespace_from_path(file_path)
  -- Try to find the .csproj file to get root namespace
  local dir = vim.fn.fnamemodify(file_path, ':h')
  local csproj_files = vim.fn.glob(dir .. '/*.csproj', true, true)
  
  -- Search up the directory tree
  local project_dir = dir
  while #csproj_files == 0 and project_dir ~= '/' do
    project_dir = vim.fn.fnamemodify(project_dir, ':h')
    csproj_files = vim.fn.glob(project_dir .. '/*.csproj', true, true)
  end
  
  if #csproj_files > 0 then
    -- Get the project name from .csproj
    local project_name = vim.fn.fnamemodify(csproj_files[1], ':t:r')
    local file_dir = vim.fn.fnamemodify(file_path, ':h')
    
    -- Get relative path from project directory to file directory
    local relative_path = vim.fn.fnamemodify(file_dir, ':s?' .. vim.pesc(project_dir) .. '??')
    
    -- Remove leading slash if present
    relative_path = relative_path:gsub('^/', '')
    
    -- Build namespace from project name and folder structure
    if relative_path ~= '' and relative_path ~= '.' then
      local parts = vim.split(relative_path, '/')
      local namespace_parts = { project_name }
      for _, part in ipairs(parts) do
        if part ~= '.' and part ~= '' and part ~= project_name then
          table.insert(namespace_parts, part)
        end
      end
      return table.concat(namespace_parts, '.')
    else
      return project_name
    end
  end
  
  return 'MyNamespace'
end

local function generate_dotnet_content(template_type, class_name, namespace)
  if template_type == 'class' then
    return string.format(
      [[namespace %s;

public class %s
{
    
}
]],
      namespace,
      class_name
    )
  elseif template_type == 'interface' then
    return string.format(
      [[namespace %s;

public interface %s
{
    
}
]],
      namespace,
      class_name
    )
  elseif template_type == 'record' then
    return string.format(
      [[namespace %s;

public record %s
{
    
}
]],
      namespace,
      class_name
    )
  elseif template_type == 'enum' then
    return string.format(
      [[namespace %s;

public enum %s
{
    
}
]],
      namespace,
      class_name
    )
  elseif template_type == 'blank' then
    return ''
  end
end

function M.new_dotnet_file()
  -- Determine the target directory
  local current_dir
  
  -- Check if we're in oil.nvim
  if vim.bo.filetype == 'oil' then
    local ok, oil = pcall(require, 'oil')
    if ok then
      current_dir = oil.get_current_dir()
    end
  end
  
  -- Fall back to current file's directory or cwd
  if not current_dir then
    current_dir = vim.fn.expand '%:p:h'
    if current_dir == '' then
      current_dir = vim.fn.getcwd()
    end
  end
  
  -- Show template picker
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  
  pickers
    .new(require('telescope.themes').get_dropdown(), {
      prompt_title = 'Select .NET File Type',
      finder = finders.new_table {
        results = dotnet_templates,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.icon .. ' ' .. entry.name,
            ordinal = entry.name,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            M.create_dotnet_file(selection.value, current_dir)
          end
        end)
        return true
      end,
    })
    :find()
end

function M.create_dotnet_file(template, target_dir)
  telescope_input('File Name (without .cs)', '', function(input)
    if not input or input == '' then
      return
    end
    
    -- Remove .cs if user added it
    local class_name = input:gsub('%.cs$', '')
    local file_path = target_dir .. '/' .. class_name .. '.cs'
    
    -- Check if file already exists
    if vim.fn.filereadable(file_path) == 1 then
      vim.notify('File already exists: ' .. file_path, vim.log.levels.ERROR)
      return
    end
    
    -- Generate content
    local namespace = get_namespace_from_path(file_path)
    local content = generate_dotnet_content(template.template, class_name, namespace)
    
    -- Create parent directories if needed
    local parent_dir = vim.fn.fnamemodify(file_path, ':h')
    vim.fn.mkdir(parent_dir, 'p')
    
    -- Write file
    local file = io.open(file_path, 'w')
    if file then
      file:write(content)
      file:close()
      
      -- Open the file
      vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
      
      -- Position cursor inside the type body
      if template.template ~= 'blank' then
        vim.cmd 'normal! G'
        vim.cmd 'normal! k'
        vim.cmd 'startinsert!'
      end
      
      vim.notify('Created ' .. template.name .. ': ' .. class_name .. '.cs', vim.log.levels.INFO)
    else
      vim.notify('Failed to create file: ' .. file_path, vim.log.levels.ERROR)
    end
  end)
end

return M
