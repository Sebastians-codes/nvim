local M = {}

local slots_path = vim.fn.stdpath('data') .. '/session_slots.json'
local slot_keys = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' }

local function normalize_session_name(name)
  if not name then
    return nil
  end
  name = vim.trim(name)
  if name == '' then
    return nil
  end
  if not name:match('%.vim$') then
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

local render_manager

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
  if manager_state.win and vim.api.nvim_win_is_valid(manager_state.win) then
    render_manager()
  end
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
  local MiniSessions = require('mini.sessions')
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
  local MiniSessions = require('mini.sessions')
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

  vim.ui.input({
    prompt = 'Rename session ' .. session_name .. ' to: ',
    default = session_name:gsub('%.vim$', ''),
  }, function(input)
    local new_name = normalize_session_name(input)
    if not new_name or new_name == session_name then
      return
    end

    local MiniSessions = require('mini.sessions')
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

local function rename_slot(slot)
  ensure_slots()
  local session_name = slots_cache[slot]
  if not session_name then
    vim.notify('No session assigned to slot ' .. format_slot(slot), vim.log.levels.WARN)
    return
  end

  rename_session_interactive(session_name)
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
  vim.ui.input({ prompt = 'Session name (without .vim): ' }, function(raw_name)
    local session_name = normalize_session_name(raw_name)
    if not session_name then
      return
    end

    local MiniSessions = require('mini.sessions')
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

local function close_manager_window()
  if manager_state.win and vim.api.nvim_win_is_valid(manager_state.win) then
    vim.api.nvim_win_close(manager_state.win, true)
  end
  if manager_state.buf and vim.api.nvim_buf_is_valid(manager_state.buf) then
    vim.api.nvim_buf_delete(manager_state.buf, { force = true })
  end
  manager_state.buf = nil
  manager_state.win = nil
  manager_state.lookup = {}
end

local function get_current_entry()
  if not (manager_state.win and vim.api.nvim_win_is_valid(manager_state.win)) then
    return nil
  end
  local cursor = vim.api.nvim_win_get_cursor(manager_state.win)
  return manager_state.lookup[cursor[1]], cursor[1]
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
  vim.ui.input({
    prompt = ('Assign %s to slot (1-9,0 for 10): '):format(session_name),
  }, function(slot)
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

local function manual_refresh()
  render_manager()
end

local function handle_enter()
  local entry = get_current_entry()
  if not entry then
    return
  end

  if entry.type == 'slot' then
    if entry.session then
      M.load_slot(entry.slot)
      close_manager_window()
    else
      prompt_for_session(entry.slot)
    end
    return
  end

  if entry.type == 'session' then
    local MiniSessions = require('mini.sessions')
    local ok, err = pcall(MiniSessions.read, entry.session.name, { force = false })
    if not ok then
      vim.notify('Failed to load session: ' .. tostring(err), vim.log.levels.ERROR)
    else
      reload_harpoon_data()
      close_manager_window()
    end
  end
end

local function handle_delete()
  local entry = get_current_entry()
  if not entry then
    return
  end

  if entry.type == 'slot' then
    if entry.session then
      clear_slot(entry.slot)
    else
      vim.notify('Slot ' .. format_slot(entry.slot) .. ' is already empty.', vim.log.levels.WARN)
    end
    return
  end

  if entry.type == 'session' then
    delete_session_file(entry.session.name)
  end
end

local function handle_rename()
  local entry = get_current_entry()
  if not entry then
    return
  end

  if entry.type == 'slot' and entry.session then
    rename_session_interactive(entry.session)
  elseif entry.type == 'session' then
    rename_session_interactive(entry.session.name)
  end
end

local function handle_assign()
  local entry = get_current_entry()
  if not entry then
    return
  end

  if entry.type == 'slot' then
    prompt_for_session(entry.slot)
  elseif entry.type == 'session' then
    assign_session_to_slot(entry.session.name)
  end
end

local function handle_new_for_slot()
  local entry = get_current_entry()
  if entry and entry.type == 'slot' then
    handle_new_session(entry.slot)
  end
end

local function handle_swap()
  local entry = get_current_entry()
  if entry and entry.type == 'slot' and entry.session then
    swap_prompt(entry.slot)
  end
end

local function ensure_manager_buffer()
  if manager_state.buf and vim.api.nvim_buf_is_valid(manager_state.buf) then
    return manager_state.buf
  end

  local buf = vim.api.nvim_create_buf(false, true)
  manager_state.buf = buf

  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'sessionmanager')

  local function map(lhs, rhs)
    vim.keymap.set('n', lhs, rhs, { buffer = buf, nowait = true, silent = true })
  end

  map('q', close_manager_window)
  map('<Esc>', close_manager_window)
  map('<CR>', handle_enter)
  map('dd', handle_delete)
  map('r', handle_rename)
  map('s', handle_assign)
  map('n', handle_new_for_slot)
  map('S', handle_swap)
  map('R', manual_refresh)

  return buf
end

render_manager = function()
  local buf = ensure_manager_buffer()
  ensure_slots()

  local sessions = collect_session_metadata()
  local lines = {}
  local lookup = {}

  local function add_line(text, meta)
    table.insert(lines, text)
    if meta then
      lookup[#lines] = meta
    end
  end

  add_line('Session Manager')
  add_line('ENTER load  dd delete/clear  r rename  s assign  n new  S swap  q close')
  add_line('')

  add_line('Slots:')
  for _, slot in ipairs(slot_keys) do
    local name = slots_cache and slots_cache[slot] or nil
    local display = name or '<empty>'
    add_line(string.format(' %2s │ %s', format_slot(slot), display), {
      type = 'slot',
      slot = slot,
      session = name,
    })
  end

  add_line('')
  add_line('Sessions:')
  if #sessions == 0 then
    add_line('  <no sessions found>')
  else
    for _, session in ipairs(sessions) do
      local slot_labels = {}
      for _, slot in ipairs(session.slots) do
        table.insert(slot_labels, slot.label)
      end
      local slot_suffix = ''
      if #slot_labels > 0 then
        slot_suffix = ' [slots ' .. table.concat(slot_labels, ',') .. ']'
      end
      add_line(string.format(' %s%s (%s)', session.name, slot_suffix, session.kind), {
        type = 'session',
        session = session,
      })
    end
  end

  local prev_cursor
  if manager_state.win and vim.api.nvim_win_is_valid(manager_state.win) then
    prev_cursor = vim.api.nvim_win_get_cursor(manager_state.win)
  end

  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  manager_state.lookup = lookup

  if manager_state.win and vim.api.nvim_win_is_valid(manager_state.win) then
    local total_lines = #lines
    local target_line = prev_cursor and math.min(prev_cursor[1], total_lines) or 1
    vim.api.nvim_win_set_cursor(manager_state.win, { target_line, 0 })

    local max_width = 0
    for _, line in ipairs(lines) do
      local width = vim.fn.strdisplaywidth(line)
      if width > max_width then
        max_width = width
      end
    end

    local height = math.min(total_lines, math.max(10, math.floor(vim.o.lines * 0.6)))
    local width = math.min(math.max(40, max_width + 2), math.floor(vim.o.columns * 0.7))
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    vim.api.nvim_win_set_config(manager_state.win, {
      relative = 'editor',
      style = 'minimal',
      border = 'rounded',
      width = width,
      height = height,
      row = row,
      col = col,
    })
  end
end

function M.assign_slot()
  vim.ui.input({ prompt = 'Assign session to slot (1-9,0 for 10): ' }, function(slot)
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
    prompt_for_session(slot)
  end)
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

  local MiniSessions = require('mini.sessions')
  local ok, err = pcall(MiniSessions.read, session_name, { force = false })
  if not ok then
    vim.notify('Failed to load session: ' .. tostring(err), vim.log.levels.ERROR)
    return
  end
  reload_harpoon_data()
end

function M.manage_slots()
  local buf = ensure_manager_buffer()

  if manager_state.win and vim.api.nvim_win_is_valid(manager_state.win) then
    vim.api.nvim_set_current_win(manager_state.win)
    render_manager()
    return
  end

  local max_width = math.max(40, vim.o.columns - 6)
  local width = math.min(math.max(50, math.floor(vim.o.columns * 0.5)), max_width)
  local max_height = math.max(12, vim.o.lines - 6)
  local height = math.min(math.max(12, #slot_keys + 8), math.floor(vim.o.lines * 0.7), max_height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  manager_state.win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    width = width,
    height = height,
    row = row,
    col = col,
    })

  vim.api.nvim_win_set_option(manager_state.win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder')
  render_manager()
end

local function quit_all_safely()
  vim.schedule(function()
    pcall(vim.cmd, 'qa')
  end)
end

function M.save_and_quit()
  local MiniSessions = require('mini.sessions')

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
    quit_all_safely()
    return
  end

  vim.ui.input({ prompt = 'Save session as (without .vim): ' }, function(input)
    local session_name = normalize_session_name(input)
    if not session_name then
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
    vim.notify('Saved session ' .. session_name .. ' and quitting')
    quit_all_safely()
  end)
end

pcall(vim.api.nvim_del_user_command, 'SessionSaveQuit')
vim.api.nvim_create_user_command('SessionSaveQuit', function()
  M.save_and_quit()
end, { desc = 'Write current session (or prompt) and quit Neovim' })

return M
