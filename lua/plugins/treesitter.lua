-- Treesitter for syntax highlighting
return {
  'nvim-treesitter/nvim-treesitter',
  build = function()
    local parsers = {
      'bash',
      'c',
      'c_sharp',
      'diff',
      'html',
      'javascript',
      'typescript',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'rust',
      'svelte',
      'vim',
      'vimdoc',
    }
    vim.cmd('TSUpdate ' .. table.concat(parsers, ' '))
  end,
}

