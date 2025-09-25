-- LSP configuration
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {
        notification = {
          window = {
            winblend = 0,
            border = "none",
          },
        },
        progress = {
          display = {
            progress_icon = { pattern = "dots", period = 1 },
          },
        },
      } },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Set default position encoding to prevent warnings
      local original_make_position_params = vim.lsp.util.make_position_params
      vim.lsp.util.make_position_params = function(win, offset_encoding)
        offset_encoding = offset_encoding or 'utf-16'
        return original_make_position_params(win, offset_encoding)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', function()
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, result)
              if not result or vim.tbl_isempty(result) then
                print 'No definition found'
                return
              end

              local item = result[1]
              if item then
                local uri = item.uri or item.targetUri
                local range = item.range or item.targetRange or item.targetSelectionRange
                
                if uri and range then
                  vim.cmd('edit ' .. vim.uri_to_fname(uri))
                  
                  -- Safe cursor positioning
                  local buf_lines = vim.api.nvim_buf_line_count(0)
                  local target_line = math.min(math.max(1, range.start.line + 1), buf_lines)
                  local target_col = math.max(0, range.start.character)
                  
                  -- Get line length to validate column
                  if target_line > 0 and target_line <= buf_lines then
                    local line_text = vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1] or ""
                    target_col = math.min(target_col, #line_text)
                  end
                  
                  vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                  vim.cmd('normal! zz')
                end
              end
            end)
          end, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Set global position encoding preference
      vim.lsp.protocol.PositionEncodingKind = vim.lsp.protocol.PositionEncodingKind or {}
      vim.lsp.protocol.PositionEncodingKind.UTF16 = 'utf-16'

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Set position encoding to utf-16 (widely supported) to avoid warnings
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { 'utf-16' }

      local function root_pattern(...)
        local patterns = { ... }

        return function(startpath)
          startpath = startpath or vim.api.nvim_buf_get_name(0)
          if not startpath or startpath == '' then
            return nil
          end

          if vim.fn.isdirectory(startpath) == 0 then
            startpath = vim.fs.dirname(startpath)
          end

          local visited = nil
          while startpath and startpath ~= '' and startpath ~= visited do
            for _, pattern in ipairs(patterns) do
              local globbed = vim.fn.glob(table.concat({ startpath, pattern }, '/'), true, true)
              if type(globbed) == 'table' then
                if next(globbed) then
                  return startpath
                end
              elseif globbed ~= '' then
                return startpath
              end
            end

            visited = startpath
            startpath = vim.fs.dirname(startpath)
          end
        end
      end

      local servers = {
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
              checkOnSave = {
                command = 'cargo check',
              },
            },
          },
        },
        csharp_ls = {
          cmd = { vim.fn.stdpath("data") .. "/mason/packages/csharp-language-server/csharp-ls" },
          filetypes = { 'cs' },
          root_dir = root_pattern('*.sln', '*.csproj', 'omnisharp.json', 'function.json'),
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        svelte = {
          capabilities = vim.tbl_deep_extend('force', {}, capabilities, {
            workspace = { didChangeWatchedFiles = false },
          }),
          filetypes = { 'svelte' },
        },
        tailwindcss = {
          filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte' },
        },
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'svelte-language-server',
        'csharp-language-server',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        automatic_enable = false,
      }

      for server_name, server in pairs(servers) do
        local server_capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        local config = vim.tbl_deep_extend('force', {}, server, { capabilities = server_capabilities })
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end

      -- Setup Gleam LSP separately (not managed by Mason)
      vim.lsp.config('gleam', {
        capabilities = capabilities,
      })
      vim.lsp.enable('gleam')
    end,
  },
}
