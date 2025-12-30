-- .NET/C# Plugin for Neovim
-- Consolidated plugin for all .NET development features including:
-- - NuGet package management
-- - Project creation and management
-- - C# file templates (Class, Interface, Record, Enum)
-- - Project references management

return {
  dir = vim.fn.stdpath 'config' .. '/lua/plugins',
  name = 'dotnet',
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  config = function()
    local M = {}

    -- ============================================================================
    -- SOLUTION AND PROJECT UTILITIES
    -- ============================================================================

    function M.find_closest_sln()
      local cwd = vim.fn.getcwd()
      local sub_sln = vim.fn.glob(cwd .. '/**/*.sln', true, true)
      local sub_slnx = vim.fn.glob(cwd .. '/**/*.slnx', true, true)
      local up_sln = {}
      local path = cwd

      while true do
        local files_sln = vim.fn.glob(path .. '/*.sln', true, true)
        local files_slnx = vim.fn.glob(path .. '/*.slnx', true, true)
        for _, f in ipairs(files_sln) do
          table.insert(up_sln, f)
        end
        for _, f in ipairs(files_slnx) do
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

      for _, s in ipairs(sub_slnx) do
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

      -- Check if it's a .slnx file (XML format)
      if sln_path:match '%.slnx$' then
        for line in content:gmatch '[^\r\n]+' do
          local proj_path = line:match '<Project Path="([^"]+)"'
          if proj_path and proj_path:match '%.csproj$' then
            proj_path = proj_path:gsub('\\', '/')
            local full_path = vim.fs.normalize(vim.fs.dirname(sln_path) .. '/' .. proj_path)
            table.insert(projects, full_path)
          end
        end
      else
        -- Parse .sln file (classic format)
        for line in content:gmatch '[^\r\n]+' do
          local _, proj_path = line:match 'Project%(".-"%).-=.-"(.-)", "(.-)"'
          if proj_path and proj_path:match '%.csproj$' then
            proj_path = proj_path:gsub('\\', '/')
            local full_path = vim.fs.normalize(vim.fs.dirname(sln_path) .. '/' .. proj_path)
            table.insert(projects, full_path)
          end
        end
      end
      return projects
    end

    -- ============================================================================
    -- NUGET PACKAGE MANAGEMENT
    -- ============================================================================

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

    -- ============================================================================
    -- PROJECT CREATION AND MANAGEMENT
    -- ============================================================================

    local templates_cache = nil

    function M.get_templates()
      if templates_cache then
        return templates_cache
      end

      local handle = io.popen 'dotnet new list --columns-all 2>/dev/null'
      if not handle then
        return {}
      end

      local result = handle:read '*a'
      handle:close()

      if result == '' then
        return {}
      end

      -- Parse the table output
      local templates = {}
      local lines = vim.split(result, '\n')
      local parsing = false

      for _, line in ipairs(lines) do
        -- Skip the header separator line
        if line:match '^%-%-%-%-' then
          parsing = true
        elseif parsing and line ~= '' then
          -- Extract template name and short name
          local name = line:match '^([^%s].-)%s%s+'
          local short_name = line:match '^[^%s].-%s%s+([^%s]+)'
          if name and short_name then
            table.insert(templates, {
              name = vim.trim(name),
              shortName = vim.trim(short_name),
            })
          end
        end
      end

      templates_cache = templates
      return templates_cache
    end

    function M.select_template(callback)
      local templates = M.get_templates()
      if #templates == 0 then
        vim.notify('Failed to load .NET templates. Make sure dotnet CLI is installed.', vim.log.levels.ERROR)
        return
      end

      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new(require('telescope.themes').get_dropdown {
          layout_config = {
            width = 0.8,
            height = 0.7,
          },
        }, {
          prompt_title = 'Select .NET Project Template',
          finder = finders.new_table {
            results = templates,
            entry_maker = function(template)
              return {
                value = template,
                display = template.name .. ' (' .. (template.shortName or template.templateId) .. ')',
                ordinal = template.name .. ' ' .. (template.shortName or template.templateId),
              }
            end,
          },
          sorter = sorters.get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                callback(selection.value)
              end
            end)
            return true
          end,
        })
        :find()
    end

    function M.create_project(template)
      vim.ui.input({
        prompt = 'Project name: ',
        default = 'MyProject',
      }, function(project_name)
        if not project_name or project_name == '' then
          return
        end

        vim.ui.input({
          prompt = 'Location (default: current directory): ',
          default = vim.fn.getcwd(),
          completion = 'dir',
        }, function(location)
          if not location or location == '' then
            location = vim.fn.getcwd()
          end

          local template_id = template.shortName or template.templateId
          local cmd = { 'dotnet', 'new', template_id, '-n', project_name, '-o', location .. '/' .. project_name }

          vim.fn.jobstart(cmd, {
            on_exit = function(job_id, exit_code, event_type)
              if exit_code == 0 then
                vim.notify('Successfully created project "' .. project_name .. '" using ' .. template.name, vim.log.levels.INFO)
                vim.notify('Location: ' .. location .. '/' .. project_name, vim.log.levels.INFO)

                -- Check for .sln or .slnx file in the location directory
                local sln_files = vim.fn.glob(location .. '/*.sln', true, true)
                local slnx_files = vim.fn.glob(location .. '/*.slnx', true, true)

                -- Combine both lists, prefer .slnx if both exist
                local solution_files = {}
                for _, f in ipairs(slnx_files) do
                  table.insert(solution_files, f)
                end
                for _, f in ipairs(sln_files) do
                  table.insert(solution_files, f)
                end

                if #solution_files > 0 then
                  local sln_path = solution_files[1]
                  local csproj_path = location .. '/' .. project_name .. '/' .. project_name .. '.csproj'

                  -- Add project to solution
                  vim.fn.jobstart({ 'dotnet', 'sln', sln_path, 'add', csproj_path }, {
                    on_exit = function(sln_job_id, sln_exit_code, sln_event_type)
                      if sln_exit_code == 0 then
                        vim.notify('Added project to solution: ' .. vim.fn.fnamemodify(sln_path, ':t'), vim.log.levels.INFO)
                      else
                        vim.notify('Failed to add project to solution', vim.log.levels.WARN)
                      end
                    end,
                  })
                end

                vim.ui.select({ 'Yes', 'No' }, {
                  prompt = 'Open project in Neovim?',
                }, function(choice)
                  if choice == 'Yes' then
                    local project_path = location .. '/' .. project_name
                    vim.fn.chdir(project_path)
                    vim.cmd('edit ' .. project_path .. '/' .. project_name .. '.csproj')
                  end
                end)
              else
                vim.notify('Failed to create project. Exit code: ' .. exit_code, vim.log.levels.ERROR)
              end
            end,
            on_stdout = function(job_id, data, event_type)
              if data and #data > 0 then
                for _, line in ipairs(data) do
                  if line ~= '' then
                    vim.notify(line, vim.log.levels.INFO)
                  end
                end
              end
            end,
            on_stderr = function(job_id, data, event_type)
              if data and #data > 0 then
                for _, line in ipairs(data) do
                  if line ~= '' then
                    vim.notify(line, vim.log.levels.ERROR)
                  end
                end
              end
            end,
          })
        end)
      end)
    end

    function M.new_project()
      M.select_template(function(template)
        M.create_project(template)
      end)
    end

    -- ============================================================================
    -- PROJECT REFERENCES MANAGEMENT
    -- ============================================================================

    -- Parse project references from .csproj
    function M.parse_project_references(csproj_path)
      local content = table.concat(vim.fn.readfile(csproj_path), '\n')
      local references = {}
      for line in content:gmatch '[^\r\n]+' do
        local ref_path = line:match '<ProjectReference Include="([^"]+)"'
        if ref_path then
          -- Convert relative path to absolute
          local project_dir = vim.fn.fnamemodify(csproj_path, ':h')
          local abs_path = vim.fn.simplify(project_dir .. '/' .. ref_path)
          table.insert(references, abs_path)
        end
      end
      return references
    end

    -- Manage project references
    function M.manage_references()
      local sln_path = M.find_closest_sln()
      if not sln_path then
        vim.notify('No .sln or .slnx file found', vim.log.levels.ERROR)
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

      -- Select the source project
      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Select Project to Manage References',
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
              local source_project = action_state.get_selected_entry()
              if source_project then
                M.show_reference_actions(source_project.value, projects)
              end
            end)
            return true
          end,
        })
        :find()
    end

    function M.show_reference_actions(source_project, all_projects)
      local references = M.parse_project_references(source_project)
      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions_mod = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      -- Build results list with actions first, then current references
      local results = {}
      table.insert(results, { type = 'action', value = 'Add Reference', display = '+ Add Reference' })
      table.insert(results, { type = 'action', value = 'Remove Reference', display = '- Remove Reference' })

      if #references > 0 then
        table.insert(results, { type = 'separator', display = '──────────────────────────' })
        table.insert(results, { type = 'header', display = 'Current References:' })
        for _, ref in ipairs(references) do
          table.insert(results, { type = 'info', display = '  • ' .. vim.fn.fnamemodify(ref, ':t:r') })
        end
      end

      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Manage References: ' .. vim.fn.fnamemodify(source_project, ':t'),
          finder = finders.new_table {
            results = results,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.display,
              }
            end,
          },
          sorter = sorters.get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions_mod.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              if selection and selection.value.type == 'action' then
                actions_mod.close(prompt_bufnr)
                if selection.value.value == 'Add Reference' then
                  M.select_reference_to_add(source_project, all_projects)
                elseif selection.value.value == 'Remove Reference' then
                  M.select_reference_to_remove(source_project)
                end
              end
            end)
            return true
          end,
        })
        :find()
    end

    function M.select_reference_to_add(source_project, all_projects)
      -- Filter out the source project from the list
      local available_projects = {}
      for _, proj in ipairs(all_projects) do
        if proj ~= source_project then
          table.insert(available_projects, proj)
        end
      end

      if #available_projects == 0 then
        vim.notify('No other projects available to reference', vim.log.levels.WARN)
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
          prompt_title = 'Select Project to Reference',
          finder = finders.new_table {
            results = available_projects,
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
              local target_project = action_state.get_selected_entry()
              if target_project then
                M.add_project_reference(source_project, target_project.value)
              end
            end)
            return true
          end,
        })
        :find()
    end

    function M.select_reference_to_remove(source_project)
      local references = M.parse_project_references(source_project)
      if #references == 0 then
        vim.notify('No project references found in ' .. vim.fn.fnamemodify(source_project, ':t'), vim.log.levels.INFO)
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
          prompt_title = 'Select Reference to Remove',
          finder = finders.new_table {
            results = references,
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
              local target_project = action_state.get_selected_entry()
              if target_project then
                M.remove_project_reference(source_project, target_project.value)
              end
            end)
            return true
          end,
        })
        :find()
    end

    function M.add_project_reference(source_project, target_project)
      if not vim.fn.filereadable(source_project) then
        vim.notify('Source project file not found: ' .. source_project, vim.log.levels.ERROR)
        return
      end
      if not vim.fn.filereadable(target_project) then
        vim.notify('Target project file not found: ' .. target_project, vim.log.levels.ERROR)
        return
      end

      vim.fn.jobstart({ 'dotnet', 'add', source_project, 'reference', target_project }, {
        on_exit = function(job_id, exit_code, event_type)
          if exit_code == 0 then
            vim.notify(
              'Successfully added reference from '
                .. vim.fn.fnamemodify(source_project, ':t')
                .. ' to '
                .. vim.fn.fnamemodify(target_project, ':t'),
              vim.log.levels.INFO
            )
          else
            vim.notify('Failed to add project reference', vim.log.levels.ERROR)
          end
        end,
        on_stderr = function(job_id, data, event_type)
          if data and #data > 0 then
            for _, line in ipairs(data) do
              if line ~= '' then
                vim.notify(line, vim.log.levels.ERROR)
              end
            end
          end
        end,
      })
    end

    function M.remove_project_reference(source_project, target_project)
      if not vim.fn.filereadable(source_project) then
        vim.notify('Source project file not found: ' .. source_project, vim.log.levels.ERROR)
        return
      end
      if not vim.fn.filereadable(target_project) then
        vim.notify('Target project file not found: ' .. target_project, vim.log.levels.ERROR)
        return
      end

      vim.fn.jobstart({ 'dotnet', 'remove', source_project, 'reference', target_project }, {
        on_exit = function(job_id, exit_code, event_type)
          if exit_code == 0 then
            vim.notify(
              'Successfully removed reference from '
                .. vim.fn.fnamemodify(source_project, ':t')
                .. ' to '
                .. vim.fn.fnamemodify(target_project, ':t'),
              vim.log.levels.INFO
            )
          else
            vim.notify('Failed to remove project reference', vim.log.levels.ERROR)
          end
        end,
        on_stderr = function(job_id, data, event_type)
          if data and #data > 0 then
            for _, line in ipairs(data) do
              if line ~= '' then
                vim.notify(line, vim.log.levels.ERROR)
              end
            end
          end
        end,
      })
    end

    -- ============================================================================
    -- C# FILE TEMPLATES
    -- ============================================================================

    local dotnet_file_templates = {
      { name = 'Class', template = 'class', icon = '📦' },
      { name = 'Interface', template = 'interface', icon = '🔌' },
      { name = 'Record', template = 'record', icon = '📋' },
      { name = 'Enum', template = 'enum', icon = '🔢' },
      { name = 'API Controller', template = 'controller', icon = '🎮' },
      { name = 'xUnit Test', template = 'xunit', icon = '🧪' },
      { name = 'Blank C# File', template = 'blank', icon = '📄' },
    }

    local function get_namespace_from_path(file_path)
      -- Normalize path separators to forward slashes for consistent handling
      file_path = file_path:gsub('\\', '/')

      -- Try to find the .csproj file to get root namespace
      local dir = vim.fn.fnamemodify(file_path, ':h')
      local csproj_files = vim.fn.glob(dir .. '/*.csproj', true, true)

      -- Determine root directory based on OS
      local root_dir = vim.fn.has('win32') == 1 and '[A-Za-z]:/$' or '^/$'

      -- Search up the directory tree
      local project_dir = dir
      while #csproj_files == 0 and not project_dir:match(root_dir) do
        project_dir = vim.fn.fnamemodify(project_dir, ':h')
        csproj_files = vim.fn.glob(project_dir .. '/*.csproj', true, true)
      end

      if #csproj_files > 0 then
        -- Get the project name from .csproj
        local project_name = vim.fn.fnamemodify(csproj_files[1], ':t:r')
        local file_dir = vim.fn.fnamemodify(file_path, ':h')

        -- Normalize project_dir to forward slashes
        project_dir = project_dir:gsub('\\', '/')
        file_dir = file_dir:gsub('\\', '/')

        -- Get relative path from project directory to file directory
        local relative_path = file_dir
        if file_dir:sub(1, #project_dir) == project_dir then
          relative_path = file_dir:sub(#project_dir + 1)
        end

        -- Remove leading slash if present
        relative_path = relative_path:gsub('^/', '')

        -- Build namespace from project name and folder structure
        if relative_path ~= '' and relative_path ~= '.' then
          local parts = vim.split(relative_path, '/')
          local namespace_parts = { project_name }
          for _, part in ipairs(parts) do
            if part ~= '.' and part ~= '' and part ~= project_name then
              table.insert(namespace_parts, part)
            end
          end
          return table.concat(namespace_parts, '.')
        else
          return project_name
        end
      end

      return 'MyNamespace'
    end

    local function generate_dotnet_content(template_type, class_name, namespace)
      if template_type == 'class' then
        return string.format(
          [[namespace %s;

public class %s
{
    
}
]],
          namespace,
          class_name
        )
      elseif template_type == 'interface' then
        return string.format(
          [[namespace %s;

public interface %s
{
    
}
]],
          namespace,
          class_name
        )
      elseif template_type == 'record' then
        return string.format(
          [[namespace %s;

public record %s
{
    
}
]],
          namespace,
          class_name
        )
      elseif template_type == 'enum' then
        return string.format(
          [[namespace %s;

public enum %s
{
    
}
]],
          namespace,
          class_name
        )
      elseif template_type == 'controller' then
        return string.format(
          [[using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace %s
{
    [Route("api/[controller]")]
    [ApiController]
    public class %s : ControllerBase
    {
        
    }
}
]],
          namespace,
          class_name
        )
      elseif template_type == 'xunit' then
        return string.format(
          [[namespace %s;

public class %s
{
    [Fact]
    public void Test1()
    {
        
    }
}
]],
          namespace,
          class_name
        )
      elseif template_type == 'blank' then
        return ''
      end
    end

    local function telescope_input(prompt_title, default_value, callback)
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local input_entries = {
        {
          display = default_value and ('Default: ' .. default_value) or 'Type and press Enter...',
          value = 'input_prompt',
          ordinal = 'input_prompt',
        },
      }

      pickers
        .new(
          require('telescope.themes').get_dropdown {
            layout_config = {
              width = 0.6,
              height = 0.2,
            },
          },
          {
            prompt_title = prompt_title,
            default_text = default_value or '',
            finder = finders.new_table {
              results = input_entries,
              entry_maker = function(entry)
                return {
                  value = entry.value,
                  display = entry.display,
                  ordinal = entry.ordinal,
                }
              end,
            },
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                local prompt_text = action_state.get_current_line()
                pcall(actions.close, prompt_bufnr)

                if prompt_text and prompt_text ~= '' then
                  callback(prompt_text)
                elseif default_value then
                  callback(default_value)
                else
                  callback(nil)
                end
              end)

              return true
            end,
          }
        )
        :find()
    end

    function M.new_dotnet_file()
      -- Determine the target directory
      local current_dir

      -- Check if we're in oil.nvim
      if vim.bo.filetype == 'oil' then
        local ok, oil = pcall(require, 'oil')
        if ok then
          current_dir = oil.get_current_dir()
        end
      end

      -- Fall back to current file's directory or cwd
      if not current_dir then
        current_dir = vim.fn.expand '%:p:h'
        if current_dir == '' then
          current_dir = vim.fn.getcwd()
        end
      end

      -- Show template picker
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new(require('telescope.themes').get_dropdown(), {
          prompt_title = 'Select .NET File Type',
          finder = finders.new_table {
            results = dotnet_file_templates,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.icon .. ' ' .. entry.name,
                ordinal = entry.name,
              }
            end,
          },
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                M.create_dotnet_file(selection.value, current_dir)
              end
            end)
            return true
          end,
        })
        :find()
    end

    function M.create_dotnet_file(template, target_dir)
      telescope_input('File Name (without .cs)', '', function(input)
        if not input or input == '' then
          return
        end

        -- Remove .cs if user added it
        local class_name = input:gsub('%.cs$', '')
        local file_path = target_dir .. '/' .. class_name .. '.cs'

        -- Check if file already exists
        if vim.fn.filereadable(file_path) == 1 then
          vim.notify('File already exists: ' .. file_path, vim.log.levels.ERROR)
          return
        end

        -- Generate content
        local namespace = get_namespace_from_path(file_path)
        local content = generate_dotnet_content(template.template, class_name, namespace)

        -- Create parent directories if needed
        local parent_dir = vim.fn.fnamemodify(file_path, ':h')
        vim.fn.mkdir(parent_dir, 'p')

        -- Write file
        local file = io.open(file_path, 'w')
        if file then
          file:write(content)
          file:close()

          -- Open the file
          vim.cmd('edit ' .. vim.fn.fnameescape(file_path))

          -- Position cursor inside the type body
          if template.template ~= 'blank' then
            vim.cmd 'normal! G'
            vim.cmd 'normal! k'
            vim.cmd 'startinsert!'
          end

          vim.notify('Created ' .. template.name .. ': ' .. class_name .. '.cs', vim.log.levels.INFO)
        else
          vim.notify('Failed to create file: ' .. file_path, vim.log.levels.ERROR)
        end
      end)
    end

    -- ============================================================================
    -- COMMANDS AND KEYMAPS
    -- ============================================================================

    -- NuGet commands
    vim.api.nvim_create_user_command('NugetSearch', function(opts)
      M.search_and_install()
    end, { desc = 'Search and install NuGet packages' })

    vim.api.nvim_create_user_command('NugetManage', function(opts)
      M.manage_packages()
    end, { desc = 'Manage installed NuGet packages' })

    -- Project commands
    vim.api.nvim_create_user_command('DotnetNew', function(opts)
      M.new_project()
    end, { desc = 'Create a new .NET project' })

    vim.api.nvim_create_user_command('DotnetReference', function(opts)
      M.manage_references()
    end, { desc = 'Manage project references' })

    -- File template commands
    vim.api.nvim_create_user_command('DotnetFile', function(opts)
      M.new_dotnet_file()
    end, { desc = 'Create a new C# file from template' })

    -- Keymaps
    vim.keymap.set('n', '<leader>ns', M.search_and_install, { desc = '[N]uget [S]earch' })
    vim.keymap.set('n', '<leader>nm', M.manage_packages, { desc = '[N]uget [M]anage' })
    vim.keymap.set('n', '<leader>np', M.new_project, { desc = '[N]ew [P]roject' })
    vim.keymap.set('n', '<leader>nr', M.manage_references, { desc = '[N]et [R]eference' })
    vim.keymap.set('n', '<leader>nf', M.new_dotnet_file, { desc = '[N]ew [F]ile' })
  end,
}
