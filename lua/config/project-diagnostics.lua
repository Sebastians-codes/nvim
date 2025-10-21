local M = {}

-- Project-wide checkers for each language
local checkers = {
  ['package.json'] = { cmd = 'npx tsc --noEmit', desc = 'TypeScript check' },
  ['Cargo.toml'] = { cmd = 'cargo check --all-targets --message-format=short', desc = 'Rust check' },
  ['pyproject.toml'] = { cmd = 'python -m mypy .', desc = 'Python check' },
  ['requirements.txt'] = { cmd = 'python -m mypy .', desc = 'Python check' },
  ['go.mod'] = { cmd = 'go build ./...', desc = 'Go check' },
  ['*.csproj'] = { cmd = 'dotnet build --nologo', desc = 'C# check' },
  ['stack.yaml'] = { cmd = 'stack build --fast --no-run-tests', desc = 'Haskell check' },
  ['cabal.project'] = { cmd = 'cabal build', desc = 'Haskell check' },
}

local function parse_error_line(line)
  -- Common error patterns for different tools
  local patterns = {
    -- Rust: --> src/main.rs:10:5
    '^%s*%-%->%s+([^:]+):(%d+):(%d+)%s*$',
    -- TypeScript: file.ts(10,5): error message
    '^(.-)%((%d+),(%d+)%):%s*(.*)$',
    -- Rust alternative: src/main.rs:10:5: error message
    '^([^:]+):(%d+):(%d+):%s*(.*)$',
    -- Python mypy: file.py:10: error message
    '^([^:]+):(%d+):%s*error:%s*(.*)$',
    -- Go: file.go:10:5: error message
    '^([^:]+):(%d+):(%d+):%s*(.*)$',
    -- Generic: file:line: message
    '^([^:]+):(%d+):%s*(.*)$',
  }

  for _, pattern in ipairs(patterns) do
    local file, line_num, col_or_msg, msg = line:match(pattern)
    if file and line_num then
      -- Handle patterns with or without column numbers
      local column = tonumber(col_or_msg)
      if column then
        return file, tonumber(line_num), column, msg or ''
      else
        return file, tonumber(line_num), 1, col_or_msg or ''
      end
    end
  end

  return nil
end

local function show_results(output, desc, code)
  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(output, '\n')

  -- Add header
  table.insert(lines, 1, desc .. (code == 0 and ' - PASSED' or ' - ERRORS FOUND'))
  table.insert(lines, 2, string.rep('-', 50))

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Store error locations for each line
  local error_locations = {}
  for i, line in ipairs(lines) do
    local file, line_num, col, msg = parse_error_line(line)
    if file and line_num then
      error_locations[i] = { file = file, line = line_num, col = col }
    end
  end

  -- Calculate window size
  local width = math.max(60, math.min(120, vim.o.columns - 10))
  local height = math.max(10, math.min(30, #lines + 2))

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = 'single',
    title = ' Project Check Results ',
    title_pos = 'center',
  })

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')

  -- Jump to error on Enter
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    noremap = true,
    silent = true,
    callback = function()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      local location = error_locations[cursor_line]

      if location then
        -- Close the floating window
        vim.api.nvim_win_close(win, true)

        -- Open the file and jump to location
        vim.cmd('edit ' .. vim.fn.fnameescape(location.file))

        -- Get buffer info to validate cursor position
        local buf_lines = vim.api.nvim_buf_line_count(0)
        local target_line = math.min(location.line, buf_lines)
        local target_col = math.max(0, location.col - 1)

        -- Get line length to validate column
        if target_line > 0 then
          local line_text = vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1] or ''
          target_col = math.min(target_col, #line_text)
        end

        vim.api.nvim_win_set_cursor(0, { target_line, target_col })

        -- Center the line in the window
        vim.cmd 'normal! zz'

        print('Jumped to ' .. location.file .. ':' .. target_line)
      else
        print 'No error location found for this line'
      end
    end,
  })

  -- Close with q or escape
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { noremap = true, silent = true })

  -- Show instructions
  if next(error_locations) then
    print 'Press <Enter> on error lines to jump to location, q to close'
  end
end

function M.run_project_check()
  -- Find what type of project this is
  for marker, checker in pairs(checkers) do
    if marker:match '%*' then
      -- Glob pattern
      local found = vim.fn.glob(marker, false, true)
      if #found > 0 then
        print('Running ' .. checker.desc .. '...')
        local output = {}
        vim.fn.jobstart(vim.split(checker.cmd, ' '), {
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data)
            vim.list_extend(output, data)
          end,
          on_stderr = function(_, data)
            vim.list_extend(output, data)
          end,
          on_exit = function(_, code)
            vim.schedule(function()
              local result = table.concat(output, '\n')
              show_results(result, checker.desc, code)
            end)
          end,
        })
        return
      end
    else
      -- Regular file
      if vim.fn.filereadable(marker) == 1 then
        print('Running ' .. checker.desc .. '...')
        local output = {}
        vim.fn.jobstart(vim.split(checker.cmd, ' '), {
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data)
            vim.list_extend(output, data)
          end,
          on_stderr = function(_, data)
            vim.list_extend(output, data)
          end,
          on_exit = function(_, code)
            vim.schedule(function()
              local result = table.concat(output, '\n')
              show_results(result, checker.desc, code)
            end)
          end,
        })
        return
      end
    end
  end

  -- Fallback: show existing diagnostics
  print 'No project type detected, showing existing diagnostics'
  vim.cmd 'Telescope diagnostics'
end

return M

