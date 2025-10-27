-- NuGet plugin for Neovim
return {
  dir = vim.fn.stdpath 'config' .. '/lua/plugins',
  name = 'nuget',
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  config = function()
    local M = {}

    function M.find_closest_sln()
      local cwd = vim.fn.getcwd()
      local sub_sln = vim.fn.glob(cwd .. '/**/*.sln', true, true)
      local up_sln = {}
      local path = cwd

      while true do
        local files = vim.fn.glob(path .. '/*.sln', true, true)
        for _, f in ipairs(files) do
          table.insert(up_sln, f)
        end
        local parent = vim.fn.fnamemodify(path, ':h')
        if parent == path then
          break
        end
        path = parent
      end

      local all_sln = {}

      for _, s in ipairs(sub_sln) do
        table.insert(all_sln, s)
      end

      for _, s in ipairs(up_sln) do
        table.insert(all_sln, s)
      end

      if #all_sln == 0 then
        return nil
      end

      -- Remove duplicates
      local unique = {}

      for _, s in ipairs(all_sln) do
        unique[s] = true
      end

      local unique_list = {}
      for s in pairs(unique) do
        table.insert(unique_list, s)
      end

      -- Sort by distance from cwd
      table.sort(unique_list, function(a, b)
        local a_rel = vim.fs.relpath(cwd, a) or a
        local b_rel = vim.fs.relpath(cwd, b) or b
        return #a_rel < #b_rel
      end)
      return unique_list[1]
    end

    function M.parse_sln_projects(sln_path)
      if not sln_path then
        return {}
      end
      local content = table.concat(vim.fn.readfile(sln_path), '\n')
      local projects = {}
      for line in content:gmatch '[^\r\n]+' do
        local _, proj_path = line:match 'Project%(".-"%).-=.-"(.-)", "(.-)"'
        if proj_path and proj_path:match '%.csproj$' then
          proj_path = proj_path:gsub('\\', '/')
          local full_path = vim.fs.normalize(vim.fs.dirname(sln_path) .. '/' .. proj_path)
          table.insert(projects, full_path)
        end
      end
      return projects
    end

    -- Get NuGet service index
    local function get_service_index()
      local curl = require 'plenary.curl'
      local response = curl.get 'https://api.nuget.org/v3/index.json'
      if response.status ~= 200 then
        return nil
      end
      return vim.fn.json_decode(response.body)
    end

    -- Find search service URL
    local function get_search_url()
      local index = get_service_index()
      if not index then
        return nil
      end
      for _, resource in ipairs(index.resources) do
        if resource['@type'] == 'SearchQueryService' then
          return resource['@id']
        end
      end
      return nil
    end

    -- Search NuGet packages
    function M.search_packages(query)
      local search_url = get_search_url()
      if not search_url then
        return {}
      end
      local curl = require 'plenary.curl'
      local response = curl.get(search_url .. '?q=' .. vim.fn.shellescape(query) .. '&take=20')
      if response.status ~= 200 then
        return {}
      end
      local data = vim.fn.json_decode(response.body)
      return data.data or {}
    end

    -- Telescope picker for package search
    function M.search_and_install()
      local sln_path = M.find_closest_sln()
      if not sln_path then
        vim.notify('No .sln file found', vim.log.levels.ERROR)
        return
      end
      local projects = M.parse_sln_projects(sln_path)
      if #projects == 0 then
        vim.notify('No .csproj files found in solution', vim.log.levels.ERROR)
        return
      end

      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Type NuGet query and press Enter to search',
          finder = finders.new_table { results = {} },
          sorter = sorters.get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local query = action_state.get_current_line()
              actions.close(prompt_bufnr)
              if query == '' then
                return
              end
              local packages = M.search_packages(query)
              if #packages == 0 then
                vim.notify('No packages found for "' .. query .. '"', vim.log.levels.WARN)
                return
              end
              pickers
                .new(require('telescope.themes').get_dropdown(), {
                  prompt_title = 'Select NuGet Package',
                  finder = finders.new_table {
                    results = packages,
                    entry_maker = function(pkg)
                      return {
                        value = pkg,
                        display = pkg.id .. ' v' .. pkg.version,
                        ordinal = pkg.id,
                      }
                    end,
                  },
                  sorter = sorters.get_generic_fuzzy_sorter(),
                  attach_mappings = function(prompt_bufnr2, map)
                    actions.select_default:replace(function()
                      actions.close(prompt_bufnr2)
                      local selection = action_state.get_selected_entry()
                      if selection then
                        M.select_project_and_install(selection.value, projects)
                      end
                    end)
                    return true
                  end,
                })
                :find()
            end)
            return true
          end,
        })
        :find()
    end

    -- Select project and install package
    function M.select_project_and_install(package, projects)
      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Select Project to Install ' .. package.id,
          finder = finders.new_table {
            results = projects,
            entry_maker = function(entry)
              return {
                value = entry,
                display = vim.fn.fnamemodify(entry, ':t'),
                ordinal = entry,
              }
            end,
          },
          sorter = sorters.get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                M.install_package(package.id, selection.value)
              end
            end)
            return true
          end,
        })
        :find()
    end

    -- Install package to project
    function M.install_package(package_id, project_path)
      if not vim.fn.filereadable(project_path) then
        vim.notify('Project file not found: ' .. project_path, vim.log.levels.ERROR)
        return
      end
      vim.fn.jobstart({ 'dotnet', 'add', project_path, 'package', package_id }, {
        on_exit = function(job_id, exit_code, event_type)
          if exit_code == 0 then
            vim.notify('Successfully installed ' .. package_id .. ' to ' .. vim.fn.fnamemodify(project_path, ':t'), vim.log.levels.INFO)
          else
            vim.notify('Failed to install ' .. package_id, vim.log.levels.ERROR)
          end
        end,
        on_stderr = function(job_id, data, event_type)
          if data and #data > 0 then
            vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR)
          end
        end,
      })
    end

    -- Parse packages from .csproj
    function M.parse_packages(csproj_path)
      local content = table.concat(vim.fn.readfile(csproj_path), '\n')
      local packages = {}
      for line in content:gmatch '[^\r\n]+' do
        local id, version = line:match '<PackageReference Include="([^"]+)" Version="([^"]+)"'
        if id then
          table.insert(packages, { id = id, version = version })
        end
      end
      return packages
    end

    -- Manage packages for a project
    function M.manage_packages()
      local sln_path = M.find_closest_sln()
      if not sln_path then
        vim.notify('No .sln file found', vim.log.levels.ERROR)
        return
      end
      local projects = M.parse_sln_projects(sln_path)
      if #projects == 0 then
        vim.notify('No .csproj files found in solution', vim.log.levels.ERROR)
        return
      end

      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Select Project to Manage Packages',
          finder = finders.new_table {
            results = projects,
            entry_maker = function(entry)
              return {
                value = entry,
                display = vim.fn.fnamemodify(entry, ':t'),
                ordinal = entry,
              }
            end,
          },
          sorter = sorters.get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                M.select_package_and_action(selection.value)
              end
            end)
            return true
          end,
        })
        :find()
    end

    -- Select package and action
    function M.select_package_and_action(project_path)
      local packages = M.parse_packages(project_path)
      if #packages == 0 then
        vim.notify('No packages found in ' .. vim.fn.fnamemodify(project_path, ':t'), vim.log.levels.INFO)
        return
      end

      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Select Package to Manage',
          finder = finders.new_table {
            results = packages,
            entry_maker = function(pkg)
              return {
                value = { project = project_path, package = pkg },
                display = pkg.id .. ' v' .. pkg.version,
                ordinal = pkg.id,
              }
            end,
          },
          sorter = sorters.get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                M.select_action(selection.value)
              end
            end)
            return true
          end,
        })
        :find()
    end

    -- Select action
    function M.select_action(data)
      local actions_list = { 'Remove', 'Update' }
      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions_mod = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Select Action for ' .. data.package.id,
          finder = finders.new_table {
            results = actions_list,
            entry_maker = function(action)
              return {
                value = { action = action, data = data },
                display = action,
                ordinal = action,
              }
            end,
          },
          sorter = sorters.get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions_mod.select_default:replace(function()
              actions_mod.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                if selection.value.action == 'Remove' then
                  M.remove_package(selection.value.data.package.id, selection.value.data.project)
                elseif selection.value.action == 'Update' then
                  M.update_package(selection.value.data.package.id, selection.value.data.project)
                end
              end
            end)
            return true
          end,
        })
        :find()
    end

    -- Remove package
    function M.remove_package(package_id, project_path)
      if not vim.fn.filereadable(project_path) then
        vim.notify('Project file not found: ' .. project_path, vim.log.levels.ERROR)
        return
      end
      vim.fn.jobstart({ 'dotnet', 'remove', project_path, 'package', package_id }, {
        on_exit = function(job_id, exit_code, event_type)
          if exit_code == 0 then
            vim.notify('Successfully removed ' .. package_id .. ' from ' .. vim.fn.fnamemodify(project_path, ':t'), vim.log.levels.INFO)
          else
            vim.notify('Failed to remove ' .. package_id, vim.log.levels.ERROR)
          end
        end,
        on_stderr = function(job_id, data, event_type)
          if data and #data > 0 then
            vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR)
          end
        end,
      })
    end

    -- Update package
    function M.update_package(package_id, project_path)
      M.install_package(package_id, project_path) -- add will update if exists
    end

    vim.api.nvim_create_user_command('NugetSearch', function(opts)
      M.search_and_install()
    end, { desc = 'Search and install NuGet packages' })

    vim.api.nvim_create_user_command('NugetManage', function(opts)
      M.manage_packages()
    end, { desc = 'Manage installed NuGet packages' })

    vim.keymap.set('n', '<leader>ns', M.search_and_install, { desc = '[N]uget [S]earch' })
    vim.keymap.set('n', '<leader>nm', M.manage_packages, { desc = '[N]uget [M]anage' })
  end,
}

