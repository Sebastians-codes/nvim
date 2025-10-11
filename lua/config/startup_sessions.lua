local M = {}
local configured = false

function M.setup()
  if configured then
    return
  end
  configured = true

  local session_manager = require('config.session_manager')

  local function detect_slot_argument()
    if vim.fn.argc() ~= 1 then
      return nil
    end

    local arg = vim.fn.argv(0)
    if not arg then
      return nil
    end

    local trimmed = vim.trim(arg)
    if trimmed == '10' then
      return '0', arg
    end

    if trimmed:match('^%d$') then
      return trimmed, arg
    end

    return nil
  end

  local slot, raw_argument = detect_slot_argument()
  if not slot then
    return
  end

  local session_loaded = false
  local has_vimenter = false
  local lazy_ready = false
  local very_lazy_ready = false
  local function cleanup_placeholder()
    if not raw_argument or raw_argument == '' then
      return
    end

    pcall(vim.cmd, 'silent! argdelete ' .. raw_argument)

    local placeholder_buf = vim.fn.bufnr(raw_argument)
    if placeholder_buf == -1 or not vim.api.nvim_buf_is_valid(placeholder_buf) then
      return
    end

    local ok_modified, modified = pcall(vim.api.nvim_buf_get_option, placeholder_buf, 'modified')
    if not ok_modified or modified then
      return
    end

    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(placeholder_buf) then
        pcall(vim.api.nvim_buf_delete, placeholder_buf, { force = true })
      end
    end)
  end

  local function load_session()
    if session_loaded then
      return
    end
    session_loaded = true

    vim.schedule(function()
      cleanup_placeholder()

      local ok, err = pcall(session_manager.load_slot, slot)
      if not ok then
        local label = slot == '0' and '10' or slot
        vim.schedule(function()
          vim.notify(string.format('Failed to load session slot %s: %s', label, err), vim.log.levels.ERROR)
        end)
      end
    end)
  end

  local function maybe_load_session()
    if session_loaded then
      return
    end
    if not (has_vimenter and lazy_ready and very_lazy_ready) then
      return
    end
    load_session()
  end

  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      has_vimenter = true
      cleanup_placeholder()

      if not lazy_ready and not package.loaded['lazy'] then
        lazy_ready = true
      end

      maybe_load_session()
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyDone',
    once = true,
    callback = function()
      lazy_ready = true
      maybe_load_session()
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    once = true,
    callback = function()
      if not lazy_ready and package.loaded['lazy'] then
        lazy_ready = true
      end
      very_lazy_ready = true
      maybe_load_session()
    end,
  })
end

return M
