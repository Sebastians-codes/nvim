local M = {}

local slots_path = vim.fn.stdpath 'data' .. '/session_slots.json'
local slot_keys = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' }
local oil_config = require 'config.oil'

local function normalize_session_name(name)
  if not name then
    return nil
  end
  name = vim.trim(name)
  if name == '' then
    return nil
  end
  if not name:match '%.vim$' then
    name = name .. '.vim'
  end
  return name
end

local json_encode = vim.json and vim.json.encode or vim.fn.json_encode
local json_decode = vim.json and vim.json.decode or vim.fn.json_decode

local function encode(data)
  local ok, result = pcall(json_encode, data)
  if not ok then
    return nil, result
  end
  return result, nil
end

local function decode(content)
  local ok, result = pcall(json_decode, content)
  if not ok then
    return nil
  end
  if type(result) ~= 'table' then
    return nil
  end
  return result
end

local function read_file(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end
  return table.concat(lines, '\n')
end

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
          width = 0.5,
          height = 0.2,
        },
      },
      {
        prompt_title = prompt_title,
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

local function write_file(path, content)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  return pcall(vim.fn.writefile, { content }, path)
end

local slots_cache

local manager_state = {
  buf = nil,
  win = nil,
  lookup = {},
}

local function reload_harpoon_data()
  local ok, harpoon = pcall(require, 'harpoon')
  if not ok or not harpoon then
    return
  end

  local ok_data, data_mod = pcall(require, 'harpoon.data')
  if not ok_data or type(data_mod.Data) ~= 'table' then
    return
  end

  local ok_new, new_data = pcall(function()
    return data_mod.Data:new(harpoon.config)
  end)
  if not ok_new or not new_data or new_data.has_error then
    return
  end

  harpoon.data = new_data
  harpoon.lists = {}
end

local function sync_harpoon()
  local ok, harpoon = pcall(require, 'harpoon')
  if not ok or not harpoon then
    return
  end

  local lists_by_key = harpoon.lists
  local config = harpoon.config or {}
  local settings = config.settings or {}
  if type(lists_by_key) ~= 'table' or type(settings.key) ~= 'function' then
    return
  end

  local original_key_fn = settings.key
  local function sync_for_key(target_key)
    settings.key = function()
      return target_key
    end
    pcall(function()
      harpoon:sync()
    end)
  end

  local has_lists = false
  for key, lists in pairs(lists_by_key) do
    if type(lists) == 'table' and next(lists) ~= nil then
      has_lists = true
      sync_for_key(key)
    end
  end

  settings.key = original_key_fn

  if not has_lists then
    pcall(function()
      harpoon:sync()
    end)
  end
end
local function write_all_buffers()
  local ok, err = pcall(vim.cmd, 'wall')
  if not ok then
    vim.notify('Failed to write buffers: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  return true
end

local function refresh_manager_view()
  -- Not needed with Telescope implementation
end

local function format_slot(slot)
  return slot == '0' and '10' or slot
end

local function ensure_slots()
  if slots_cache then
    return
  end

  local content = read_file(slots_path)
  if not content then
    slots_cache = {}
    return
  end

  local decoded = decode(content)
  if not decoded then
    slots_cache = {}
    return
  end

  slots_cache = decoded
end

local function save_slots()
  ensure_slots()
  local encoded, err = encode(slots_cache)
  if not encoded then
    vim.notify('Failed to save session slots: ' .. tostring(err), vim.log.levels.ERROR)
    return
  end
  local ok, write_err = write_file(slots_path, encoded)
  if not ok then
    vim.notify('Failed to write session slots file: ' .. tostring(write_err), vim.log.levels.ERROR)
  end
end

local function list_sessions()
  local MiniSessions = require 'mini.sessions'
  local sessions = {}

  local directory = MiniSessions.config.directory or ''
  if directory ~= '' then
    local paths = vim.fn.globpath(directory, '*.vim', false, true)
    for _, path in ipairs(paths) do
      if vim.fn.filereadable(path) == 1 then
        table.insert(sessions, vim.fn.fnamemodify(path, ':t'))
      end
    end
  end

  local local_name = MiniSessions.config.file or ''
  if local_name ~= '' then
    local local_path = vim.fn.getcwd() .. '/' .. local_name
    if vim.fn.filereadable(local_path) == 1 then
      table.insert(sessions, local_name)
    end
  end

  table.sort(sessions)
  return sessions
end

local function get_session_info(session_name)
  if not session_name then
    return nil
  end
  local MiniSessions = require 'mini.sessions'
  local cfg = MiniSessions.config
  if session_name == cfg.file and cfg.file ~= '' then
    return vim.fn.getcwd() .. '/' .. session_name, 'local'
  end
  local directory = cfg.directory or ''
  if directory == '' then
    return nil
  end
  return directory .. '/' .. session_name, 'global'
end

local function clear_slot(slot)
  ensure_slots()
  slots_cache[slot] = nil
  save_slots()
  vim.notify('Cleared session slot ' .. format_slot(slot))
  refresh_manager_view()
end

local function swap_slots(slot_a, slot_b)
  ensure_slots()
  slots_cache[slot_a], slots_cache[slot_b] = slots_cache[slot_b], slots_cache[slot_a]
  save_slots()
  vim.notify(('Swapped session slots %s and %s'):format(format_slot(slot_a), format_slot(slot_b)))
  refresh_manager_view()
end

local function rename_session_interactive(session_name, opts)
  opts = opts or {}
  ensure_slots()

  local path, kind = get_session_info(session_name)
  if not path or vim.fn.filereadable(path) ~= 1 then
    vim.notify('Cannot find session file for ' .. session_name, vim.log.levels.ERROR)
    return
  end

  if kind ~= 'global' then
    vim.notify('Renaming is only supported for global sessions.', vim.log.levels.WARN)
    return
  end

  telescope_input('Rename Session', session_name:gsub('%.vim$', ''), function(input)
    local new_name = normalize_session_name(input)
    if not new_name or new_name == session_name then
      return
    end

    local MiniSessions = require 'mini.sessions'
    local directory = MiniSessions.config.directory or ''
    if directory == '' then
      vim.notify('Session directory is not configured.', vim.log.levels.ERROR)
      return
    end
    local new_path = directory .. '/' .. new_name
    if vim.fn.filereadable(new_path) == 1 then
      vim.notify('A session with that name already exists.', vim.log.levels.ERROR)
      return
    end

    local ok = vim.fn.rename(path, new_path) == 0
    if not ok then
      vim.notify('Failed to rename session file.', vim.log.levels.ERROR)
      return
    end

    for key, value in pairs(slots_cache) do
      if value == session_name then
        slots_cache[key] = new_name
      end
    end
    save_slots()

    if vim.v.this_session == path then
      vim.v.this_session = new_path
    end

    vim.notify(('Renamed session %s to %s'):format(session_name, new_name))

    if opts.after then
      opts.after(new_name, new_path)
    end
    refresh_manager_view()
  end)
end

local function swap_prompt(slot)
  ensure_slots()
  if not slots_cache[slot] then
    vim.notify('No session assigned to slot ' .. format_slot(slot), vim.log.levels.WARN)
    return
  end

  local choices = {}
  for _, other in ipairs(slot_keys) do
    if other ~= slot then
      local name = slots_cache[other]
      table.insert(choices, {
        slot = other,
        label = string.format('%s: %s', format_slot(other), name or '<empty>'),
      })
    end
  end

  vim.ui.select(choices, {
    prompt = 'Swap slot ' .. format_slot(slot) .. ' with:',
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    swap_slots(slot, choice.slot)
  end)
end

local function handle_new_session(slot)
  telescope_input('New Session Name', nil, function(raw_name)
    local session_name = normalize_session_name(raw_name)
    if not session_name then
      return
    end

    local MiniSessions = require 'mini.sessions'
    sync_harpoon()
    MiniSessions.write(session_name, { force = true })

    ensure_slots()
    slots_cache[slot] = session_name
    save_slots()
    vim.notify(('Saved current session as %s and assigned to slot %s'):format(session_name, format_slot(slot)))
    refresh_manager_view()
  end)
end

local function handle_assign_existing(slot, session_name)
  ensure_slots()
  slots_cache[slot] = session_name
  save_slots()
  vim.notify(('Assigned session %s to slot %s'):format(session_name, format_slot(slot)))
  refresh_manager_view()
end

local function prompt_for_session(slot)
  local sessions = list_sessions()
  local entries = {
    { label = 'Save current state as new session', action = 'new' },
  }

  for _, name in ipairs(sessions) do
    table.insert(entries, { label = name, action = 'existing', session = name })
  end

  table.insert(entries, { label = 'Clear slot', action = 'clear' })

  vim.ui.select(entries, {
    prompt = 'Select session for slot ' .. format_slot(slot),
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    if choice.action == 'new' then
      handle_new_session(slot)
    elseif choice.action == 'existing' then
      handle_assign_existing(slot, choice.session)
    elseif choice.action == 'clear' then
      clear_slot(slot)
    end
  end)
end

local function collect_session_metadata()
  ensure_slots()
  local assignments = {}
  if slots_cache then
    for slot, value in pairs(slots_cache) do
      if value then
        assignments[value] = assignments[value] or {}
        table.insert(assignments[value], {
          key = slot,
          label = format_slot(slot),
        })
      end
    end
  end

  local sessions = {}
  for _, name in ipairs(list_sessions()) do
    local path, kind = get_session_info(name)
    if path then
      local slot_info = assignments[name] or {}
      table.sort(slot_info, function(a, b)
        return tonumber(a.label) < tonumber(b.label)
      end)
      table.insert(sessions, {
        name = name,
        path = path,
        kind = kind or 'global',
        slots = slot_info,
      })
    end
  end

  table.sort(sessions, function(a, b)
    if a.kind ~= b.kind then
      return a.kind == 'local'
    end
    return a.name < b.name
  end)

  return sessions
end

local function delete_session_file(session_name)
  ensure_slots()
  local path, kind = get_session_info(session_name)
  if not path then
    vim.notify('Cannot resolve session ' .. session_name, vim.log.levels.ERROR)
    return
  end
  if kind ~= 'global' then
    vim.notify('Deleting local sessions is not supported from this manager.', vim.log.levels.WARN)
    return
  end

  local file_exists = vim.fn.filereadable(path) == 1
  if file_exists then
    local ok = vim.fn.delete(path)
    if ok ~= 0 then
      vim.notify('Failed to delete session ' .. session_name, vim.log.levels.ERROR)
      return
    end
  else
    vim.notify('Session file was missing; cleared references for ' .. session_name, vim.log.levels.WARN)
  end

  for slot, value in pairs(slots_cache) do
    if value == session_name then
      slots_cache[slot] = nil
    end
  end
  save_slots()

  if vim.v.this_session == path then
    vim.v.this_session = ''
  end

  if file_exists then
    vim.notify('Deleted session ' .. session_name)
  end
  refresh_manager_view()
end

local function assign_session_to_slot(session_name)
  telescope_input(string.format('Assign %s to Slot', session_name), nil, function(slot)
    if not slot then
      return
    end
    slot = vim.trim(slot)
    if slot == '10' then
      slot = '0'
    end
    if not vim.tbl_contains(slot_keys, slot) then
      vim.notify('Invalid slot: ' .. slot, vim.log.levels.ERROR)
      return
    end
    handle_assign_existing(slot, session_name)
  end)
end

local function create_session_picker()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  ensure_slots()
  local sessions = collect_session_metadata()

  local entries = {}

  table.insert(entries, {
    display = 'Enter Load  dd Delete  r Rename  s Assign  n New  S Swap',
    value = 'header',
    ordinal = '000_header',
  })

  table.insert(entries, {
    display = 'Slots --------------------------------------',
    value = 'slots_header',
    ordinal = '001_slots_header',
  })

  for _, slot in ipairs(slot_keys) do
    local name = slots_cache and slots_cache[slot] or nil
    local icon = name and '[X]' or '[ ]'
    local display_name = name or '<empty>'
    table.insert(entries, {
      display = string.format('  %s %s %s', icon, format_slot(slot), display_name),
      value = { type = 'slot', slot = slot, session = name },
      ordinal = string.format('002_slot_%s_%s', slot, name or 'empty'),
    })
  end

  table.insert(entries, {
    display = 'Sessions ------------------------------------',
    value = 'sessions_header',
    ordinal = '003_sessions_header',
  })

  if #sessions == 0 then
    table.insert(entries, {
      display = '  <no sessions found>',
      value = 'no_sessions',
      ordinal = '004_no_sessions',
    })
  else
    for _, session in ipairs(sessions) do
      local slot_labels = {}
      for _, slot in ipairs(session.slots) do
        table.insert(slot_labels, slot.label)
      end
      local slot_info = #slot_labels > 0 and string.format(' [%s]', table.concat(slot_labels, ',')) or ''
      local kind_icon = session.kind == 'local' and '(L)' or '(G)'
      local display = string.format('  %s %s%s %s %s', kind_icon, session.name, slot_info, kind_icon, session.kind)
      table.insert(entries, {
        display = display,
        value = { type = 'session', session = session },
        ordinal = string.format('005_session_%s_%s', session.kind, session.name),
      })
    end
  end

  pickers
    .new(
      require('telescope.themes').get_dropdown {
        layout_config = {
          width = 0.5,
          height = 0.4,
        },
      },
      {
        prompt_title = 'Session Manager',
        finder = finders.new_table {
          results = entries,
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
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end

            local value = selection.value
            if type(value) == 'table' then
              if value.type == 'slot' then
                if value.session then
                  M.load_slot(value.slot)
                else
                  prompt_for_session(value.slot)
                end
              elseif value.type == 'session' then
                oil_config.ensure_loaded()
                local MiniSessions = require 'mini.sessions'
                local ok, err = pcall(MiniSessions.read, value.session.name, { force = false })
                if not ok then
                  vim.notify('Failed to load session: ' .. tostring(err), vim.log.levels.ERROR)
                else
                  reload_harpoon_data()
                end
              end
            end
            pcall(actions.close, prompt_bufnr)
          end)

          -- Delete action (dd)
          map('n', 'dd', function()
            local selection = action_state.get_selected_entry()
            if not selection or type(selection.value) ~= 'table' then
              return
            end

            local value = selection.value
            if value.type == 'slot' then
              if value.session then
                clear_slot(value.slot)
                vim.notify('Cleared session slot ' .. format_slot(value.slot))
              else
                vim.notify('Slot ' .. format_slot(value.slot) .. ' is already empty.', vim.log.levels.WARN)
              end
            elseif value.type == 'session' then
              delete_session_file(value.session.name)
              vim.notify('Deleted session ' .. value.session.name)
            end
            pcall(actions.close, prompt_bufnr)
            vim.defer_fn(function()
              M.manage_slots()
            end, 100)
          end)

          -- Rename action (r)
          map('n', 'r', function()
            local selection = action_state.get_selected_entry()
            if not selection or type(selection.value) ~= 'table' then
              return
            end

            local value = selection.value
            if value.type == 'slot' and value.session then
              rename_session_interactive(value.session)
            elseif value.type == 'session' then
              rename_session_interactive(value.session.name)
            end
            pcall(actions.close, prompt_bufnr)
          end)

          -- Assign action (s)
          map('n', 's', function()
            local selection = action_state.get_selected_entry()
            if not selection or type(selection.value) ~= 'table' then
              return
            end

            local value = selection.value
            if value.type == 'slot' then
              prompt_for_session(value.slot)
            elseif value.type == 'session' then
              assign_session_to_slot(value.session.name)
            end
            pcall(actions.close, prompt_bufnr)
          end)

          -- New session action (n)
          map('n', 'n', function()
            local selection = action_state.get_selected_entry()
            if selection and type(selection.value) == 'table' and selection.value.type == 'slot' then
              handle_new_session(selection.value.slot)
              pcall(actions.close, prompt_bufnr)
            end
          end)

          -- Swap action (S)
          map('n', 'S', function()
            local selection = action_state.get_selected_entry()
            if selection and type(selection.value) == 'table' and selection.value.type == 'slot' and selection.value.session then
              swap_prompt(selection.value.slot)
              pcall(actions.close, prompt_bufnr)
            end
          end)

          return true
        end,
      }
    )
    :find()
end

function M.assign_slot_to_session(slot)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local sessions = list_sessions()

  local session_entries = {
    {
      display = 'Save current state as new session',
      value = { action = 'new' },
      ordinal = 'new_session',
    },
  }

  for _, name in ipairs(sessions) do
    local path, kind = get_session_info(name)
    local kind_icon = kind == 'local' and '(L)' or '(G)'
    table.insert(session_entries, {
      display = string.format('%s %s %s %s', kind_icon, name, kind_icon, kind),
      value = { action = 'existing', session = name },
      ordinal = string.format('session_%s_%s', kind, name),
    })
  end

  table.insert(session_entries, {
    display = 'Clear slot',
    value = { action = 'clear' },
    ordinal = 'clear_slot',
  })

  pickers
    .new(
      require('telescope.themes').get_dropdown {
        layout_config = {
          width = 0.5,
          height = 0.4,
        },
      },
      {
        prompt_title = string.format('Assign Session to Slot %s', format_slot(slot)),
        finder = finders.new_table {
          results = session_entries,
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
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end

            local choice = selection.value
            pcall(actions.close, prompt_bufnr)

            if choice.action == 'new' then
              handle_new_session(slot)
            elseif choice.action == 'existing' then
              handle_assign_existing(slot, choice.session)
            elseif choice.action == 'clear' then
              clear_slot(slot)
            end
          end)

          return true
        end,
      }
    )
    :find()
end

function M.assign_slot()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  ensure_slots()

  local slot_entries = {}
  for _, slot in ipairs(slot_keys) do
    local name = slots_cache and slots_cache[slot] or nil
    local icon = name and '[X]' or '[ ]'
    local display_name = name or '<empty>'
    local status = name and ' (assigned)' or ' (empty)'
    table.insert(slot_entries, {
      display = string.format('%s %s %s%s', icon, format_slot(slot), display_name, status),
      value = slot,
      ordinal = string.format('slot_%s_%s', slot, name or 'empty'),
    })
  end

  pickers
    .new(
      require('telescope.themes').get_dropdown {
        layout_config = {
          width = 0.4,
          height = 0.3,
        },
      },
      {
        prompt_title = 'Select Slot to Assign',
        finder = finders.new_table {
          results = slot_entries,
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
            local selection = action_state.get_selected_entry()
            if not selection then
              return
            end

            local slot = selection.value
            pcall(actions.close, prompt_bufnr)

            M.assign_slot_to_session(slot)
          end)

          return true
        end,
      }
    )
    :find()
end

function M.load_slot(slot)
  ensure_slots()
  slot = tostring(slot)
  if slot == '10' then
    slot = '0'
  end
  if not vim.tbl_contains(slot_keys, slot) then
    vim.notify('Invalid slot: ' .. slot, vim.log.levels.ERROR)
    return
  end

  local session_name = slots_cache[slot]
  if not session_name then
    vim.notify('No session assigned to slot ' .. format_slot(slot), vim.log.levels.WARN)
    return
  end

  oil_config.ensure_loaded()
  local MiniSessions = require 'mini.sessions'
  local ok, err = pcall(MiniSessions.read, session_name, { force = false })
  if not ok then
    vim.notify('Failed to load session: ' .. tostring(err), vim.log.levels.ERROR)
    return
  end
  reload_harpoon_data()
end

function M.manage_slots()
  create_session_picker()
end

local function quit_all_safely()
  vim.schedule(function()
    pcall(vim.cmd, 'qa')
  end)
end

function M.save_and_quit()
  local MiniSessions = require 'mini.sessions'

  if vim.v.this_session ~= '' then
    if not write_all_buffers() then
      return
    end
    sync_harpoon()
    local ok, err = pcall(MiniSessions.write, nil, { force = true })
    if not ok then
      vim.notify('Failed to update current session: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    refresh_manager_view()
    vim.notify 'Updated current session and quitting'
    quit_all_safely()
  else
    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local conf = require('telescope.config').values
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'

    local save_entries = {}

    table.insert(save_entries, {
      display = 'Save as new session...',
      value = { action = 'save_new' },
      ordinal = 'save_new',
    })

    table.insert(save_entries, {
      display = 'Quit without saving',
      value = { action = 'quit_only' },
      ordinal = 'quit_only',
    })

    pickers
      .new(
        require('telescope.themes').get_dropdown {
          layout_config = {
            width = 0.5,
            height = 0.3,
          },
        },
        {
          prompt_title = 'Save Session & Quit',
          finder = finders.new_table {
            results = save_entries,
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
              local selection = action_state.get_selected_entry()
              if not selection then
                return
              end

              local choice = selection.value
              pcall(actions.close, prompt_bufnr)

              if choice.action == 'save_new' then
                telescope_input('Enter Session Name', nil, function(input)
                  local session_name = normalize_session_name(input)
                  if not session_name then
                    vim.notify('Invalid session name', vim.log.levels.ERROR)
                    return
                  end

                  if not write_all_buffers() then
                    return
                  end

                  sync_harpoon()
                  local ok, err = pcall(MiniSessions.write, session_name, { force = true })
                  if not ok then
                    vim.notify('Failed to save session: ' .. tostring(err), vim.log.levels.ERROR)
                    return
                  end

                  local path = get_session_info(session_name)
                  if path then
                    vim.v.this_session = path
                  end
                  sync_harpoon()
                  refresh_manager_view()
                  vim.notify('Saved session "' .. session_name .. '" and quitting')
                  quit_all_safely()
                end)
              elseif choice.action == 'quit_only' then
                quit_all_safely()
              end
            end)

            return true
          end,
        }
      )
      :find()
  end
end

pcall(vim.api.nvim_del_user_command, 'SessionSaveQuit')
vim.api.nvim_create_user_command('SessionSaveQuit', function()
  M.save_and_quit()
end, { desc = 'Write current session (or prompt) and quit Neovim' })

return M
