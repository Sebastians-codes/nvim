local M = {}

local data_path = vim.fn.stdpath 'data'
local theme_file = data_path .. '/current_theme.txt'

M.transparency = {
  enabled = true,
  groups = {
    -- Core UI
    'Normal', 'NormalFloat', 'SignColumn', 'StatusLine', 'StatusLineNC',
    'TabLine', 'TabLineFill', 'TabLineSel', 'ColorColumn', 'CursorLine',
    'CursorColumn', 'Pmenu', 'PmenuSbar', 'PmenuSel', 'PmenuThumb',
    'Folded', 'FoldColumn', 'LineNr', 'CursorLineNr',

    -- Telescope (comprehensive)
    'TelescopeNormal', 'TelescopeBorder', 'TelescopePromptNormal',
    'TelescopePromptBorder', 'TelescopeResultsNormal', 'TelescopeResultsBorder',
    'TelescopePreviewNormal', 'TelescopePreviewBorder', 'TelescopeTitle',
    'TelescopePromptTitle', 'TelescopePreviewTitle', 'TelescopeResultsTitle',
    'TelescopeSelection', 'TelescopeSelectionCaret', 'TelescopeMatching',
    'TelescopeMultiSelection', 'TelescopeMultiIcon', 'TelescopePreviewMessage',
    'TelescopePreviewMessageFillchar', 'TelescopePreviewSticky', 'TelescopePreviewCharDev',
    'TelescopePreviewDirectory', 'TelescopePreviewBlock', 'TelescopePreviewLink',
    'TelescopePreviewSocket', 'TelescopePreviewRead', 'TelescopePreviewWrite',
    'TelescopePreviewExecute', 'TelescopePreviewHyphen', 'TelescopePreviewPipe',
    'TelescopePreviewLine', 'TelescopePreviewMatch', 'TelescopePreviewGroup',

    -- WhichKey (comprehensive)
    'WhichKeyFloat', 'FloatBorder', 'WhichKeyNormal', 'WhichKeyBorder',
    'WhichKey', 'WhichKeyGroup', 'WhichKeyDesc', 'WhichKeySeparator',
    'WhichKeyValue', 'WhichKeyIcon', 'WhichKeyIconGrey',

    -- Oil (file manager)
    'OilDir', 'OilDirIcon', 'OilFile', 'OilLink', 'OilCreate', 'OilDelete',
    'OilMove', 'OilCopy', 'OilChange', 'OilRestore', 'OilPermissionNone',
    'OilPermissionRead', 'OilPermissionWrite', 'OilPermissionExecute',
    'OilTypeDir', 'OilTypeFile', 'OilTypeLink', 'OilTypeSocket', 'OilTypeBlock',
    'OilTypeChar', 'OilTypeFifo', 'OilTypeUnknown', 'OilPreview',

    -- Other plugins
    'MiniStatuslineModeReplace', 'MiniStatuslineModeCommand', 'MiniStatuslineModeOther',
    'MiniStatuslineDevinfo', 'MiniStatuslineFilename', 'MiniStatuslineFileinfo',
    'MiniStatuslineInactive', 'NvimTreeNormal', 'NvimTreeStatuslineNc',
    'BufferLineFill', 'BufferLineBackground', 'BufferLineBuffer',
    'BufferLineTab', 'BufferLineTabSelected', 'BufferLineTabClose',
    'LualineNormal', 'LualineInactive', 'LualineInsert', 'LualineVisual',
    'LualineReplace', 'LualineCommand', 'LualineTerminal',
    'GitSignsAdd', 'GitSignsChange', 'GitSignsDelete',
    'DiagnosticFloatingError', 'DiagnosticFloatingWarn', 'DiagnosticFloatingInfo', 'DiagnosticFloatingHint',

    -- Generic floating windows and popups
    'NormalNC', 'MsgArea', 'MsgSeparator', 'VertSplit', 'WinSeparator',
    'EndOfBuffer', 'QuickFixLine', 'qfSeparator', 'WildMenu',
  }
}

M.themes = {
  mygawa = function()
    require('themes.mygawa').setup()
  end,
  sakurai = function()
    require('themes.sakurai').setup()
  end,
  myrarch = function()
    require('themes.myrarch').setup()
  end,
  nes = function()
    require('themes.nes').setup()
  end,
  tokyonight = function()
    require('themes.tokyonight').setup()
  end,
  catppuccin = function()
    require('themes.catppuccin').setup()
  end,
  gruvbox = function()
    require('themes.gruvbox').setup()
  end,
  nord = function()
    require('themes.nord').setup()
  end,
  ['rose-pine'] = function()
    require('themes.rose-pine').setup()
  end,
  nightfox = function()
    require('themes.nightfox').setup()
  end,
  onedark = function()
    require('themes.onedark').setup()
  end,
}

function M.load_theme(theme_name, silent)
  if not M.themes[theme_name] then
    vim.notify('Theme "' .. theme_name .. '" not found', vim.log.levels.ERROR)
    return false
  end

  M.themes[theme_name]()

  -- Apply transparency if enabled
  if M.transparency.enabled then
    for _, group in ipairs(M.transparency.groups) do
      vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
    end
  end

  local file = io.open(theme_file, 'w')
  if file then
    file:write(theme_name)
    file:close()
  end

  -- Silent theme switching - no notifications
  return true
end

function M.get_saved_theme()
  local file = io.open(theme_file, 'r')
  if file then
    local theme = file:read '*all'
    file:close()
    return theme
  end
  return 'mygawa'
end

function M.toggle_transparency()
  M.transparency.enabled = not M.transparency.enabled

  -- Reapply current theme with new transparency setting
  local current_theme = M.get_saved_theme()
  if M.themes[current_theme] then
    M.themes[current_theme]()
    if M.transparency.enabled then
      for _, group in ipairs(M.transparency.groups) do
        vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
      end
    end
  end

  local status = M.transparency.enabled and 'enabled' or 'disabled'
  vim.notify('Transparency ' .. status, vim.log.levels.INFO)
end

function M.show_theme_picker()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local theme_list = {}
  for name, _ in pairs(M.themes) do
    table.insert(theme_list, name)
  end
  table.sort(theme_list)

  pickers
    .new({}, {
      prompt_title = 'Select Theme',
      finder = finders.new_table {
        results = theme_list,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          M.load_theme(selection[1])
        end)
        return true
      end,
    })
    :find()
end

return M
