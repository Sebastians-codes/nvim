local M = {}

local DEFAULT_PREVIEW_SPLIT = 'belowright'
local AUTOCMD_GROUP = 'OilAutoPreview'

local function load_oil()
  local ok, oil = pcall(require, 'oil')
  if ok then
    return oil
  end

  local lazy_ok, lazy = pcall(require, 'lazy')
  if lazy_ok and lazy and lazy.load then
    pcall(lazy.load, { plugins = { 'oil.nvim' } })
    ok, oil = pcall(require, 'oil')
    if ok then
      return oil
    end
  end

  return nil
end

local function with_default_preview(opts)
  opts = opts or {}
  local preview = opts.preview
  if preview == nil then
    opts.preview = { split = DEFAULT_PREVIEW_SPLIT }
  elseif type(preview) == 'table' and preview.split == nil then
    opts.preview = vim.tbl_extend('keep', { split = DEFAULT_PREVIEW_SPLIT }, preview)
  end
  return opts
end

function M.open_with_preview(dir, opts, cb)
  local oil = load_oil()
  if not oil then
    vim.notify('oil.nvim is not available', vim.log.levels.WARN)
    return
  end

  opts = with_default_preview(opts)
  oil.open(dir, opts, cb)
end

local function ensure_preview_for_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_call(bufnr, function()
    local oil = load_oil()
    if not oil or vim.bo.filetype ~= 'oil' then
      return
    end

    local util_ok, util = pcall(require, 'oil.util')
    if not util_ok then
      return
    end

    local entry_ok, entry = pcall(oil.get_cursor_entry)
    if not entry_ok or not entry then
      if not vim.b.oil_preview_pending then
        vim.b.oil_preview_pending = true
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.b.oil_preview_pending = nil
            ensure_preview_for_buffer(bufnr)
          end
        end, 50)
      end
      return
    end

    local preview_win = util.get_preview_win { include_not_owned = true }
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
      vim.b.oil_preview_pending = nil
      return
    end

    vim.b.oil_preview_pending = nil
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) ~= bufnr then
        local buf = vim.api.nvim_win_get_buf(win)
        if
          vim.api.nvim_buf_is_valid(buf)
          and vim.api.nvim_buf_get_name(buf) == ''
          and vim.bo[buf].buftype == ''
          and vim.bo[buf].filetype == ''
          and not vim.bo[buf].modified
        then
          pcall(vim.api.nvim_win_close, win, true)
        end
      end
    end
    pcall(oil.open_preview, { split = DEFAULT_PREVIEW_SPLIT })
  end)
end

function M.setup(opts)
  local oil = require 'oil'
  oil.setup(opts)

  local group = vim.api.nvim_create_augroup(AUTOCMD_GROUP, { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'OilEnter',
    callback = function(event)
      local buf = (event.data and event.data.buf) or event.buf
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      vim.api.nvim_buf_call(buf, function()
        if vim.bo.filetype ~= 'oil' or vim.b.oil_preview_autoloaded then
          return
        end
        vim.b.oil_preview_autoloaded = true
      end)

      vim.defer_fn(function()
        ensure_preview_for_buffer(buf)
      end, 10)
    end,
  })

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    callback = function(event)
      if not vim.api.nvim_buf_is_valid(event.buf) then
        return
      end

      if vim.bo[event.buf].filetype ~= 'oil' then
        return
      end

      vim.defer_fn(function()
        ensure_preview_for_buffer(event.buf)
      end, 10)
    end,
  })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = function(event)
      if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].filetype == 'oil' then
        vim.b[event.buf].oil_preview_autoloaded = nil
        vim.b[event.buf].oil_preview_pending = nil
      end
    end,
  })

  pcall(vim.api.nvim_del_user_command, 'OilWithPreview')
  vim.api.nvim_create_user_command('OilWithPreview', function(command_opts)
    local target = command_opts.args ~= '' and command_opts.args or nil
    M.open_with_preview(target)
  end, { nargs = '?', complete = 'dir' })
end

function M.handle_startup_directory()
  if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    vim.schedule(function()
      M.open_with_preview(vim.fn.argv(0))
    end)
  end
end

function M.ensure_loaded()
  return load_oil() ~= nil
end

return M
