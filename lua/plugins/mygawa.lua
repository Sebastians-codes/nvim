local M = {}

function M.setup()
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' then
    vim.cmd 'syntax reset'
  end

  vim.o.termguicolors = true
  vim.g.colors_name = 'mygawa'

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('Normal', { fg = '#DCD7BA', bg = 'NONE' })
  hi('NormalFloat', { fg = '#DCD7BA', bg = 'NONE' })
  hi('FloatBorder', { fg = '#2A2A37', bg = 'NONE' })
  hi('CursorLine', { bg = 'NONE' })
  hi('LineNr', { fg = '#54546D', bg = 'NONE' })
  hi('CursorLineNr', { fg = '#FFA066', bg = 'NONE', bold = true })
  hi('StatusLine', { fg = '#C8C093', bg = 'NONE' })
  hi('StatusLineNC', { fg = '#727169', bg = 'NONE' })
  hi('VertSplit', { fg = '#16161D', bg = 'NONE' })
  hi('WinSeparator', { fg = '#16161D', bg = 'NONE' })

  hi('Pmenu', { fg = '#DCD7BA', bg = 'NONE' })
  hi('PmenuSel', { fg = '#DCD7BA', bg = '#2D4F67' })
  hi('PmenuSbar', { bg = 'NONE' })
  hi('PmenuThumb', { bg = '#54546D' })

  hi('Search', { bg = '#2D4F67' })
  hi('IncSearch', { fg = '#1F1F28', bg = '#FF9E3B' })
  hi('CurSearch', { fg = '#1F1F28', bg = '#FF9E3B' })

  hi('Visual', { bg = '#223249' })
  hi('VisualNOS', { bg = '#223249' })

  hi('Comment', { fg = '#727169', italic = true })
  hi('String', { fg = '#98BB6C' })
  hi('Character', { fg = '#98BB6C' })
  hi('Number', { fg = '#D27E99' })
  hi('Boolean', { fg = '#FFA066' })
  hi('Float', { fg = '#D27E99' })

  hi('Identifier', { fg = '#FFA066' })
  hi('Function', { fg = '#7E9CD8' })
  hi('Statement', { fg = '#957FB8', bold = true })
  hi('Conditional', { fg = '#957FB8', bold = true })
  hi('Repeat', { fg = '#957FB8', bold = true })
  hi('Label', { fg = '#957FB8', bold = true })
  hi('Operator', { fg = '#E6C384' })
  hi('Keyword', { fg = '#957FB8', bold = true })
  hi('Exception', { fg = '#FF5D62', bold = true })

  hi('PreProc', { fg = '#FFA066' })
  hi('Include', { fg = '#FFA066' })
  hi('Define', { fg = '#957FB8' })
  hi('Macro', { fg = '#E46876' })
  hi('PreCondit', { fg = '#FFA066' })

  hi('Type', { fg = '#7AA89F' })
  hi('StorageClass', { fg = '#957FB8' })
  hi('Structure', { fg = '#957FB8' })
  hi('Typedef', { fg = '#957FB8' })

  hi('Special', { fg = '#7FB4CA' })
  hi('SpecialChar', { fg = '#7FB4CA' })
  hi('Tag', { fg = '#E6C384' })
  hi('Delimiter', { fg = '#9CABCA' })
  hi('SpecialComment', { fg = '#727169' })
  hi('Debug', { fg = '#E82424' })

  hi('Underlined', { underline = true })
  hi('Ignore', { fg = '#727169' })
  hi('Error', { fg = '#E82424', bold = true })
  hi('Todo', { fg = '#FFA066', bold = true })
  hi('Warning', { fg = '#FF9E3B' })

  hi('DiffAdd', { fg = '#76946A', bg = 'NONE' })
  hi('DiffDelete', { fg = '#C34043', bg = 'NONE' })
  hi('DiffChange', { fg = '#DCA561', bg = 'NONE' })
  hi('DiffText', { fg = '#7E9CD8', bg = 'NONE' })

  hi('Folded', { fg = '#727169', bg = 'NONE' })
  hi('FoldColumn', { fg = '#727169', bg = 'NONE' })
  hi('SignColumn', { bg = 'NONE' })

  hi('QuickFixLine', { bg = 'NONE' })
  hi('PmenuKind', { fg = '#7E9CD8', bg = 'NONE' })
  hi('PmenuKindSel', { fg = '#7E9CD8', bg = '#2D4F67' })
  hi('PmenuExtra', { fg = '#727169', bg = 'NONE' })
  hi('PmenuExtraSel', { fg = '#727169', bg = '#2D4F67' })

  hi('TabLine', { fg = '#DCD7BA', bg = 'NONE' })
  hi('TabLineSel', { fg = '#7E9CD8', bg = 'NONE', bold = true })
  hi('TabLineFill', { bg = 'NONE' })

  hi('SpellBad', { fg = '#E82424', underline = true })
  hi('SpellCap', { fg = '#FF9E3B', underline = true })
  hi('SpellLocal', { fg = '#7E9CD8', underline = true })
  hi('SpellRare', { fg = '#6A9589', underline = true })

  hi('MatchParen', { fg = '#E6C384', bold = true })
  hi('ModeMsg', { fg = '#DCD7BA' })
  hi('MoreMsg', { fg = '#6A9589' })
  hi('Question', { fg = '#6A9589' })
  hi('WarningMsg', { fg = '#FF9E3B' })
  hi('ErrorMsg', { fg = '#E82424' })

  hi('Directory', { fg = '#7E9CD8', bold = true })
  hi('EndOfBuffer', { fg = '#16161D' })

  hi('LSPReferenceText', { bg = 'NONE', underline = true })
  hi('LSPReferenceRead', { bg = 'NONE', underline = true })
  hi('LSPReferenceWrite', { bg = 'NONE', underline = true })

  hi('DiagnosticError', { fg = '#E82424' })
  hi('DiagnosticWarn', { fg = '#FF9E3B' })
  hi('DiagnosticInfo', { fg = '#7E9CD8' })
  hi('DiagnosticHint', { fg = '#6A9589' })
  hi('DiagnosticUnderlineError', { sp = '#E82424', underline = true })
  hi('DiagnosticUnderlineWarn', { sp = '#FF9E3B', underline = true })
  hi('DiagnosticUnderlineInfo', { sp = '#7E9CD8', underline = true })
  hi('DiagnosticUnderlineHint', { sp = '#6A9589', underline = true })

  hi('@variable', { fg = '#DCD7BA' })
  hi('@variable.builtin', { fg = '#FF5D62' })
  hi('@variable.parameter', { fg = '#B8B4D0' })
  hi('@variable.member', { fg = '#E6C384' })
  hi('@constant', { fg = '#FFA066' })
  hi('@constant.builtin', { fg = '#FFA066' })
  hi('@constant.import', { fg = '#FFA066' })
  hi('@module', { fg = '#E6C384' })
  hi('@string', { fg = '#98BB6C' })
  hi('@character', { fg = '#98BB6C' })
  hi('@number', { fg = '#D27E99' })
  hi('@boolean', { fg = '#FFA066' })
  hi('@float', { fg = '#D27E99' })
  hi('@function', { fg = '#7E9CD8' })
  hi('@function.builtin', { fg = '#7FB4CA' })
  hi('@function.method', { fg = '#7FB4CA' })
  hi('@function.macro', { fg = '#E46876' })
  hi('@constructor', { fg = '#7FB4CA' })
  hi('@keyword', { fg = '#957FB8', bold = true })
  hi('@keyword.function', { fg = '#957FB8' })
  hi('@keyword.operator', { fg = '#957FB8' })
  hi('@keyword.return', { fg = '#957FB8', bold = true })
  hi('@keyword.exception', { fg = '#FF5D62', bold = true })
  hi('@operator', { fg = '#E6C384' })
  hi('@punctuation.delimiter', { fg = '#9CABCA' })
  hi('@punctuation.bracket', { fg = '#9CABCA' })
  hi('@type', { fg = '#7AA89F' })
  hi('@type.builtin', { fg = '#7AA89F' })
  hi('@attribute', { fg = '#957FB8' })
  hi('@property', { fg = '#E6C384' })
  hi('@tag', { fg = '#E6C384' })
  hi('@tag.attribute', { fg = '#957FB8' })
  hi('@tag.delimiter', { fg = '#9CABCA' })

  hi('MiniStatuslineModeNormal', { fg = '#000000', bg = '#DCD7BA', bold = true })
  hi('MiniStatuslineModeInsert', { fg = '#000000', bg = '#DCD7BA', bold = true })
  hi('MiniStatuslineModeVisual', { fg = '#000000', bg = '#DCD7BA', bold = true })
  hi('MiniStatuslineModeReplace', { fg = '#000000', bg = '#DCD7BA', bold = true })
  hi('MiniStatuslineModeCommand', { fg = '#000000', bg = '#DCD7BA', bold = true })
  hi('MiniStatuslineModeOther', { fg = '#000000', bg = '#DCD7BA', bold = true })
  hi('MiniStatuslineDevinfo', { fg = '#DCD7BA', bg = 'NONE' })
  hi('MiniStatuslineFilename', { fg = '#DCD7BA', bg = 'NONE' })
  hi('MiniStatuslineFileinfo', { fg = '#DCD7BA', bg = 'NONE' })
  hi('MiniStatuslineInactive', { fg = '#727169', bg = 'NONE' })
end

M.setup()
return {}
