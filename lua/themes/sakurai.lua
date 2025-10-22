local M = {
  setup = function()
        vim.cmd 'highlight clear'
        if vim.fn.exists 'syntax_on' == 1 then
          vim.cmd 'syntax reset'
        end

        vim.o.background = 'dark'
        vim.g.colors_name = 'sakurai'

        local c = {
          black = '#0f0820',
          dark_gray = '#1a1429',
          gray = '#2a2435',
          light_gray = '#4a4555',
          white = '#e8e0f0',
          foreground = '#c8b8e0',
          cursor = '#e0d0ff',
          line_bg = '#251d35',
          active_fg = '#ff9eb5',
          focus_fg = '#ffb3c1',
          property = '#8fb3ff',
          number = '#d4a085',
          parameter = '#d4c2f0',
          class = '#b084cc',
          namespace = '#6b9dff',
          keyword = '#9bb8ff',
          control_kw = '#7a9eff',
          interface = '#e495b3',
          func = '#c8a2ff',
          operator = '#e0d0ff',
          string = '#a6d4ff',
          comment = '#6b5980',
          error = '#ff6b8a',
          warning = '#ffcc66',
          info = '#66b3ff',
        }

        local function hi(group, fg, bg, attr)
          local cmd = 'highlight ' .. group
          if fg and fg ~= '' then
            cmd = cmd .. ' guifg=' .. fg
          end
          if bg and bg ~= '' then
            cmd = cmd .. ' guibg=' .. bg
          end
          if attr and attr ~= '' then
            cmd = cmd .. ' gui=' .. attr
          end
          vim.cmd(cmd)
        end

        -- Basic highlights
        hi('Normal', c.white, 'NONE', '')
        hi('NormalNC', c.white, 'NONE', '')
        hi('Cursor', c.black, c.cursor, '')
        hi('CursorLine', '', 'NONE', '')
        hi('CursorColumn', '', c.line_bg, '')
        hi('LineNr', c.light_gray, '', '')
        hi('CursorLineNr', c.focus_fg, '', 'bold')
        hi('Visual', '', '#3d2952', '')
        hi('VisualNOS', '', '#3d2952', '')
        hi('Search', c.black, c.number, '')
        hi('IncSearch', c.black, c.active_fg, '')
        hi('MatchParen', '', '#4a2d66', '')
        hi('VertSplit', c.gray, '', '')
        hi('WinSeparator', c.gray, '', '')
        hi('StatusLine', c.active_fg, 'NONE', '')
        hi('StatusLineNC', c.foreground, 'NONE', '')
        hi('TabLine', c.foreground, 'NONE', '')
        hi('TabLineFill', '', 'NONE', '')
        hi('TabLineSel', c.active_fg, 'NONE', 'bold')
        hi('Pmenu', c.warning, 'NONE', '')
        hi('PmenuSel', c.active_fg, 'NONE', '')
        hi('PmenuSbar', '', 'NONE', '')
        hi('PmenuThumb', '', 'NONE', '')
        hi('FloatBorder', c.gray, 'NONE', '')
        hi('NormalFloat', c.white, 'NONE', '')
        hi('Folded', c.comment, '#3d2952', '')
        hi('FoldColumn', c.light_gray, '', '')
        hi('DiffAdd', '', '#2d4a2d', '')
        hi('DiffChange', '', '#2d3d5c', '')
        hi('DiffDelete', '', '#5c2d2d', '')
        hi('DiffText', '', '#4a4a66', '')
        hi('DiagnosticError', c.error, '', '')
        hi('DiagnosticWarn', c.warning, '', '')
        hi('DiagnosticInfo', c.info, '', '')
        hi('DiagnosticHint', c.comment, '', '')
        hi('ErrorMsg', c.error, '', '')
        hi('WarningMsg', c.warning, '', '')
        hi('ModeMsg', c.active_fg, '', '')
        hi('MoreMsg', c.active_fg, '', '')
        hi('Question', c.active_fg, '', '')

        -- Syntax
        hi('Comment', c.comment, '', 'italic')
        hi('Constant', c.number, '', '')
        hi('String', c.string, '', '')
        hi('Character', c.string, '', '')
        hi('Number', c.number, '', '')
        hi('Boolean', c.number, '', '')
        hi('Float', c.number, '', '')
        hi('Identifier', c.property, '', '')
        hi('Function', c.func, '', '')
        hi('Statement', c.keyword, '', '')
        hi('Conditional', c.control_kw, '', '')
        hi('Repeat', c.control_kw, '', '')
        hi('Label', c.keyword, '', '')
        hi('Operator', c.operator, '', '')
        hi('Keyword', c.keyword, '', '')
        hi('Exception', c.control_kw, '', '')
        hi('PreProc', c.keyword, '', '')
        hi('Include', c.keyword, '', '')
        hi('Define', c.keyword, '', '')
        hi('Macro', c.keyword, '', '')
        hi('PreCondit', c.keyword, '', '')
        hi('Type', c.class, '', '')
        hi('StorageClass', c.keyword, '', '')
        hi('Structure', c.class, '', '')
        hi('Typedef', c.class, '', '')
        hi('Special', c.operator, '', '')
        hi('SpecialChar', c.operator, '', '')
        hi('Tag', c.class, '', '')
        hi('Delimiter', c.operator, '', '')
        hi('SpecialComment', c.comment, '', 'bold')
        hi('Debug', c.error, '', '')

        -- TreeSitter
        hi('@variable', c.white, '', '')
        hi('@variable.builtin', c.class, '', '')
        hi('@variable.parameter', c.parameter, '', '')
        hi('@variable.member', c.property, '', '')

        -- Variable declarations vs usage
        hi('@lsp.type.variable', c.parameter, '', '') -- sakura pink tint for usage
        hi('@lsp.mod.declaration', c.white, '', '') -- keep original white for declarations

        -- LSP semantic tokens for properties (must override LSP)
        hi('@lsp.type.property', c.property, '', '')
        hi('@lsp.type.member', c.property, '', '')
        hi('@lsp.type.property.typescript', c.property, '', '')
        hi('@lsp.type.property.typescriptreact', c.property, '', '')

        -- Primitive types - multiple ways TreeSitter might highlight them
        hi('@lsp.type.builtinType', '#ccb3ff', '', '')
        hi('@type.builtin', '#ccb3ff', '', '')
        hi('@keyword.type', '#ccb3ff', '', '')
        hi('@type.builtin.typescript', '#ccb3ff', '', '')
        hi('@type.builtin.javascript', '#ccb3ff', '', '')
        hi('@type.primitive', '#ccb3ff', '', '')

        -- Enums
        hi('@lsp.type.enum', '#9ba0c7', '', '') -- more muted enum color
        hi('@lsp.type.enumMember', '#9ba0c7', '', '')
        hi('@constant', c.number, '', '')
        hi('@constant.builtin', c.number, '', '')
        hi('@constant.macro', c.keyword, '', '')
        hi('@string', c.string, '', '')
        hi('@string.escape', c.string, '', 'bold')
        hi('@string.special', c.string, '', 'italic')
        hi('@string.regexp', c.string, '', '')
        hi('@character', c.string, '', '')
        hi('@character.special', c.string, '', 'bold')
        hi('@number', c.number, '', '')
        hi('@number.float', c.number, '', '')
        hi('@boolean', c.number, '', '')
        hi('@float', c.number, '', '')
        hi('@function', c.func, '', '')
        hi('@function.builtin', c.func, '', '')
        hi('@function.call', c.func, '', '')
        hi('@function.macro', c.func, '', '')
        hi('@method', c.func, '', '')
        hi('@method.call', c.func, '', '')
        hi('@constructor', c.class, '', '')
        hi('@parameter', c.parameter, '', '')
        hi('@keyword', c.keyword, '', '')
        hi('@keyword.function', c.keyword, '', '')
        hi('@keyword.operator', c.keyword, '', '')
        hi('@keyword.return', c.control_kw, '', '')
        hi('@keyword.conditional', c.control_kw, '', '')
        hi('@keyword.repeat', c.control_kw, '', '')
        hi('@keyword.exception', c.control_kw, '', '')
        hi('@operator', c.operator, '', '')
        hi('@punctuation.delimiter', c.operator, '', '')
        hi('@punctuation.bracket', c.operator, '', '')
        hi('@punctuation.special', c.operator, '', '')
        hi('@type', c.class, '', '')
        hi('@type.builtin', c.keyword, '', '')
        hi('@type.definition', c.class, '', '')
        hi('@type.qualifier', c.keyword, '', '')
        hi('@property', c.property, '', '')
        hi('@field', c.property, '', '')
        hi('@namespace', c.namespace, '', '')
        hi('@module', c.namespace, '', '')
        hi('@label', c.keyword, '', '')
        hi('@comment', c.comment, '', 'italic')
        hi('@tag', c.class, '', '')
        hi('@tag.attribute', c.property, '', '')
        hi('@tag.delimiter', c.operator, '', '')

        -- JSX/HTML specific highlights
        hi('@tag.javascript', c.class, '', '')
        hi('@tag.tsx', c.class, '', '')
        hi('@tag.jsx', c.class, '', '')
        hi('@tag.builtin.javascript', c.keyword, '', '')
        hi('@tag.builtin.tsx', c.keyword, '', '')
        hi('@tag.builtin.jsx', c.keyword, '', '')
        hi('@constructor.javascript', c.class, '', '')
        hi('@constructor.tsx', c.class, '', '')
        hi('@constructor.jsx', c.class, '', '')

        -- LSP UI (non-semantic)
        hi('LspSignatureActiveParameter', c.parameter, '', 'bold')
        hi('LspCodeLens', c.comment, '', '')
        hi('LspInlayHint', c.comment, '', 'italic')

        -- Language-specific highlights
        hi('@type.go', c.keyword, '', '')
        hi('@type.builtin.go', c.keyword, '', '')
        hi('@keyword.function.go', c.control_kw, '', '')
        hi('@keyword.return.go', '#6b7aff', '', '')
        hi('@function.macro.rust', c.class, '', '')
        hi('@keyword.return.c_sharp', '#6b7aff', '', '')
        hi('@keyword.exception.c_sharp', '#cc6699', '', '')

        -- Telescope
        hi('TelescopeNormal', c.white, 'NONE', '')
        hi('TelescopeBorder', c.gray, 'NONE', '')
        hi('TelescopeSelection', c.active_fg, 'NONE', '')
        hi('TelescopeSelectionCaret', c.active_fg, 'NONE', '')
        hi('TelescopeMatching', c.number, 'NONE', '')

        -- Which-key
        hi('WhichKey', c.property, 'NONE', '')
        hi('WhichKeyGroup', c.class, 'NONE', '')
        hi('WhichKeyDesc', c.white, 'NONE', '')
        hi('WhichKeyFloat', '', 'NONE', '')
        hi('WhichKeyBorder', c.gray, 'NONE', '')

        -- Fidget (LSP Progress)
        hi('FidgetTask', c.white, 'NONE', '')
        hi('FidgetTitle', c.active_fg, 'NONE', '')
        hi('FidgetSpinner', c.info, 'NONE', '')
        hi('FidgetNormal', c.white, 'NONE', '')

        -- Terminal colors (inspired by sunset/twilight)
        vim.g.terminal_color_0 = c.black
        vim.g.terminal_color_1 = '#ff6b8a'
        vim.g.terminal_color_2 = '#66ff99'
        vim.g.terminal_color_3 = '#ffcc66'
        vim.g.terminal_color_4 = '#6b9dff'
        vim.g.terminal_color_5 = '#cc6699'
        vim.g.terminal_color_6 = '#66ccff'
        vim.g.terminal_color_7 = '#e8e0f0'
        vim.g.terminal_color_8 = '#4a4555'
        vim.g.terminal_color_9 = '#ff9eb5'
        vim.g.terminal_color_10 = '#99ffb3'
        vim.g.terminal_color_11 = '#ffd699'
        vim.g.terminal_color_12 = '#99b3ff'
        vim.g.terminal_color_13 = '#e495b3'
        vim.g.terminal_color_14 = '#99d6ff'
        vim.g.terminal_color_15 = '#f0e8ff'

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function()
        vim.defer_fn(function()
          vim.cmd 'hi @lsp.type.property guifg=#8fb3ff'
          vim.cmd 'hi @lsp.type.member guifg=#8fb3ff'
          vim.cmd 'hi @lsp.type.property.typescript guifg=#8fb3ff'
          vim.cmd 'hi @lsp.type.property.typescriptreact guifg=#8fb3ff'
          vim.cmd 'hi @type.builtin guifg=#ccb3ff'
          vim.cmd 'hi @type.builtin.typescript guifg=#ccb3ff'
          vim.cmd 'hi @keyword.type guifg=#ccb3ff'
        end, 100)
      end,
    })
  end
}

return M

