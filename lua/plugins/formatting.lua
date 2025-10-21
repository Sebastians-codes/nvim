-- Code formatting
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    formatters = {
      csharpier = {
        command = 'csharpier',
        args = { 'format', '$FILENAME' },
        stdin = false,
        tmpfile_format = '.cs',
      },
      prettier = {
        command = 'prettier',
        args = { '--stdin-filepath', '$FILENAME' },
      },
    },
    format_on_save = function(bufnr)
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      json = { 'prettier' },
      css = { 'prettier' },
      html = { 'prettier' },
      c = { 'clang_format' },
      cpp = { 'clang_format' },
      --  cs = { 'csharpier' },
    },
  },
}
