local M = {}

local data_path = vim.fn.stdpath 'data'
local state_file = data_path .. '/theme_state.json'

M.transparency = {
  enabled = true,
  groups = {
    -- Core UI
    'Normal', 'NormalFloat', 'SignColumn', 'StatusLine', 'StatusLineNC',
    'TabLine', 'TabLineFill', 'TabLineSel', 'ColorColumn', 'CursorLine',
    'CursorColumn', 'Pmenu', 'PmenuSbar', 'PmenuSel', 'PmenuThumb',
    'Folded', 'FoldColumn', 'LineNr', 'CursorLineNr', 'CursorLineSign', 'CursorLineFold',

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
    'NormalNC', 'MsgArea', 'MsgSeparator',
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
  ['tokyonight-moon'] = function()
    require('themes.tokyonight-moon').setup()
  end,
  ['tokyonight-storm'] = function()
    require('themes.tokyonight-storm').setup()
  end,
  ['tokyonight-night'] = function()
    require('themes.tokyonight-night').setup()
  end,

  ['catppuccin-latte'] = function()
    require('themes.catppuccin-latte').setup()
  end,
  ['catppuccin-frappe'] = function()
    require('themes.catppuccin-frappe').setup()
  end,
  ['catppuccin-macchiato'] = function()
    require('themes.catppuccin-macchiato').setup()
  end,
  gruvbox = function()
    require('themes.gruvbox').setup()
  end,
  dracula = function()
    require('themes.dracula').setup()
  end,
  everforest = function()
    require('themes.everforest').setup()
  end,
  kanagawa = function()
    require('themes.kanagawa').setup()
  end,
  oxocarbon = function()
    require('themes.oxocarbon').setup()
  end,
  github = function()
    require('themes.github').setup()
  end,
  vscode = function()
    require('themes.vscode').setup()
  end,
  monokai = function()
    require('themes.monokai').setup()
  end,
  solarized = function()
    require('themes.solarized').setup()
  end,
  ayu = function()
    require('themes.ayu').setup()
  end,
  palenight = function()
    require('themes.palenight').setup()
  end,
  sonokai = function()
    require('themes.sonokai').setup()
  end,
  cyberdream = function()
    require('themes.cyberdream').setup()
  end,
  melange = function()
    require('themes.melange').setup()
  end,
  modus = function()
    require('themes.modus').setup()
  end,
  poimandres = function()
    require('themes.poimandres').setup()
  end,
  onenord = function()
    require('themes.onenord').setup()
  end,
  material = function()
    require('themes.material').setup()
  end,
  nightfly = function()
    require('themes.nightfly').setup()
  end,
  moonfly = function()
    require('themes.moonfly').setup()
  end,
  edge = function()
    require('themes.edge').setup()
  end,
  ['gruvbox-material'] = function()
    require('themes.gruvbox-material').setup()
  end,

  iceberg = function()
    require('themes.iceberg').setup()
  end,
  tender = function()
    require('themes.tender').setup()
  end,

  nord = function()
    require('themes.nord').setup()
  end,

  nightfox = function()
    require('themes.nightfox').setup()
  end,
  onedark = function()
    require('themes.onedark').setup()
  end,
  ['rose-pine'] = function()
    require('themes.rose-pine').setup()
  end,
}

function M.load_theme(theme_name, silent)
  if not M.themes[theme_name] then
    if not silent then
      vim.notify('Theme "' .. theme_name .. '" not found', vim.log.levels.ERROR)
    end
    return false
  end

  M.themes[theme_name]()

  -- Apply transparency if enabled
    if M.transparency.enabled then
      for _, group in ipairs(M.transparency.groups) do
        vim.api.nvim_set_hl(0, group, { bg = 'NONE' })
      end
      vim.opt.fillchars:append({ eob = ' ' })
    end

    if not M.transparency.enabled then
      vim.opt.fillchars:append({ eob = '~' })
    end

  local file = io.open(state_file, 'w')
  if file then
    file:write(vim.json.encode({theme = theme_name, transparent = M.transparency.enabled}))
    file:close()
  else
    if not silent then
      vim.notify('Failed to save theme state', vim.log.levels.ERROR)
    end
  end

  return true
end

function M.get_saved_theme()
  local ok, lines = pcall(vim.fn.readfile, state_file)
  if ok and #lines > 0 then
    local content = table.concat(lines, '\n')
    local decoded = vim.json.decode(content)
    if decoded then
      return decoded.theme or 'mygawa'
    end
  end
  return 'mygawa'
end

function M.get_transparency_state()
  local ok, lines = pcall(vim.fn.readfile, state_file)
  if ok and #lines > 0 then
    local content = table.concat(lines, '\n')
    local decoded = vim.json.decode(content)
    if decoded then
      return decoded.transparent or false
    end
  end
  return false
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
      vim.opt.fillchars:append({ eob = ' ' })
    end
  end

  local file = io.open(state_file, 'w')
  if file then
    file:write(vim.json.encode({theme = current_theme, transparent = M.transparency.enabled}))
    file:close()
  else
    vim.notify('Failed to save theme state', vim.log.levels.ERROR)
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

   local current_theme = M.get_saved_theme()
   local original_theme = current_theme -- Store for restoration
   local selected = false -- Flag to track if user made a selection
   local theme_list = {}
   local theme_names = {}
   for name, _ in pairs(M.themes) do
     table.insert(theme_names, name)
   end
   table.sort(theme_names)
   for _, name in ipairs(theme_names) do
     local display = name
     if name == current_theme then
       display = display .. " [Current]"
     end
     if name == "myrarch" or name == "mygawa" or name == "sakurai" or name == "rose_pine" then
       display = display .. " (Custom)"
     end
     table.insert(theme_list, { display = display, value = name })
   end
  -- Add index numbers to display
  for i, theme in ipairs(theme_list) do
    theme.index = i
    theme.display = string.format("%2d. %s", i, theme.display)
  end

  -- Live preview function
  local function preview_theme(entry)
    if entry and entry.value ~= current_theme then
      -- Apply the preview theme
      M.load_theme(entry.value, true) -- Silent mode
      current_theme = entry.value
    end
  end

  pickers
    .new({}, {
      prompt_title = 'Select Theme (Transparency: ' .. (M.transparency.enabled and 'Enabled' or 'Disabled') .. ')',
      finder = finders.new_table {
        results = theme_list,
        entry_maker = function(entry)
          return {
            value = entry.value,
            display = entry.display,
            ordinal = string.format("%02d", entry.index or 1) .. " " .. entry.value, -- Search by index (01,10) or name
            path = vim.fn.stdpath('config') .. '/init.lua', -- Preview sample file
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = conf.file_previewer({}),
      attach_mappings = function(prompt_bufnr, map)
        -- Load first theme on open
        if #theme_list > 0 then
          M.load_theme(theme_list[1].value, true)
        end

        -- Live preview on selection movement
        local function preview_current()
          local entry = action_state.get_selected_entry(prompt_bufnr)
          preview_theme(entry)
        end

        -- Override movement keys to include preview
        map('n', 'j', function()
          actions.move_selection_next(prompt_bufnr)
          preview_current()
        end)
        map('n', 'k', function()
          actions.move_selection_previous(prompt_bufnr)
          preview_current()
        end)
        map('n', '<Down>', function()
          actions.move_selection_next(prompt_bufnr)
          preview_current()
        end)
        map('n', '<Up>', function()
          actions.move_selection_previous(prompt_bufnr)
          preview_current()
        end)

        map('i', '<Down>', function()
          actions.move_selection_next(prompt_bufnr)
          preview_current()
        end)
        map('i', '<Up>', function()
          actions.move_selection_previous(prompt_bufnr)
          preview_current()
        end)

        -- Initial preview
        vim.defer_fn(preview_current, 10)

        -- Preview on search/filter changes
        vim.api.nvim_create_autocmd('TextChangedI', {
          buffer = prompt_bufnr,
          callback = function()
            vim.defer_fn(preview_current, 50)
          end,
        })

        -- Toggle transparency with Ctrl+T
        map('i', '<C-t>', function()
          M.toggle_transparency()
        end)
        map('n', '<C-t>', function()
          M.toggle_transparency()
        end)

        actions.select_default:replace(function()
          selected = true
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          -- Keep the preview theme as final selection
          M.load_theme(selection.value)
        end)

        -- Restore original theme when picker closes without selection
        vim.api.nvim_create_autocmd('BufLeave', {
          buffer = prompt_bufnr,
          once = true,
          callback = function()
            -- Only restore if we didn't make a final selection
            if not selected and current_theme ~= original_theme then
              M.load_theme(original_theme, true)
            end
          end,
        })

        return true
      end,
    })
    :find()
end

return M
