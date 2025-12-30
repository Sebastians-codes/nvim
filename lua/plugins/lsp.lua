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
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = {
              winblend = 0,
              border = 'none',
            },
          },
          progress = {
            display = {
              progress_icon = { pattern = 'dots', period = 1 },
            },
          },
        },
      },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Set default position encoding to prevent warnings
      local original_make_position_params = vim.lsp.util.make_position_params
      vim.lsp.util.make_position_params = function(win, offset_encoding)
        offset_encoding = offset_encoding or 'utf-16'
        return original_make_position_params(win, offset_encoding)
      end

      -- Link extension methods to regular method highlighting
      vim.api.nvim_set_hl(0, '@lsp.type.extensionMethod', { link = '@lsp.type.method' })
      vim.api.nvim_set_hl(0, '@lsp.typemod.method.static', { link = '@lsp.type.method' })

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
                    local line_text = vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1] or ''
                    target_col = math.min(target_col, #line_text)
                  end

                  vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                  vim.cmd 'normal! zz'
                end
              end
            end)
          end, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename with Telescope UI
          vim.keymap.set('n', '<leader>rn', function()
            require('utils.rename').rename()
          end, { buffer = event.buf, desc = 'LSP: [R]e[n]ame' })

          -- Code actions for normal and visual mode
          vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: [C]ode [A]ction' })
          vim.keymap.set({ 'n', 'x' }, '<C-Space>', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: [C]ode [A]ction' })

          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = function()
                if vim.api.nvim_buf_is_valid(event.buf) then
                  vim.lsp.buf.document_highlight()
                end
              end,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = function()
                if vim.api.nvim_buf_is_valid(event.buf) then
                  vim.lsp.buf.clear_references()
                end
              end,
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

      local servers = {
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
              checkOnSave = true,
            },
          },
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

      require('mason').setup {
        registries = {
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',
        },
      }

      local ensure_installed = {
        'csharpier',
        'lua-language-server',
        'prettier',
        'roslyn',
        'rust-analyzer',
        'rzls',
      }
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        automatic_installation = false,
      }

      local vim_lsp_config = type(vim.lsp) == 'table'
        and type(vim.lsp.config) == 'table'
        and getmetatable(vim.lsp.config)
        and type(getmetatable(vim.lsp.config).__call) == 'function'
        and type(vim.lsp.enable) == 'function'

      if vim_lsp_config then
        for server_name, server in pairs(servers) do
          local server_capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          local override_config = vim.tbl_deep_extend('force', {}, server, { capabilities = server_capabilities })

          if type(override_config.root_dir) == 'function' then
            local old_root_dir = override_config.root_dir
            local ok_info, info = pcall(debug.getinfo, old_root_dir, 'u')
            local expects_on_dir = ok_info and info and type(info.nparams) == 'number' and info.nparams >= 2

            if not expects_on_dir then
              override_config.root_dir = function(bufnr, on_dir)
                local ok_call, root = pcall(old_root_dir, bufnr)
                if not ok_call then
                  vim.notify(string.format('Failed to resolve root_dir for %s: %s', server_name, root), vim.log.levels.ERROR)
                  return
                end

                if type(root) == 'function' then
                  local inner_ok, inner_root = pcall(root, bufnr)
                  if not inner_ok then
                    vim.notify(string.format('Failed to resolve root_dir for %s: %s', server_name, inner_root), vim.log.levels.ERROR)
                    return
                  end
                  root = inner_root
                end

                if root then
                  on_dir(root)
                end
              end
            end
          end

          local ok_config, err_config = pcall(vim.lsp.config, server_name, override_config)
          if not ok_config then
            vim.notify(string.format('Failed to apply LSP config overrides for %s: %s', server_name, err_config), vim.log.levels.ERROR)
          else
            local ok_enable, err_enable = pcall(vim.lsp.enable, server_name)
            if not ok_enable then
              vim.notify(string.format('Failed to enable LSP %s: %s', server_name, err_enable), vim.log.levels.ERROR)
            end
          end
        end
      else
        local lspconfig = require 'lspconfig'

        for server_name, server in pairs(servers) do
          local server_capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          local config = vim.tbl_deep_extend('force', {}, server, { capabilities = server_capabilities })
          if lspconfig[server_name] then
            lspconfig[server_name].setup(config)
          else
            vim.notify(string.format('LSP config for %s is missing in nvim-lspconfig', server_name), vim.log.levels.WARN)
          end
        end
      end
    end,
  },
}
