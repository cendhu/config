-- Project switcher: quickly cd to any project or worktree
-- Uses Telescope to fuzzy-find directories under configured roots.
-- Bound to <leader>fp ("find project").

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>fp",
      function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local conf = require("telescope.config").values

        -- Directories to scan for projects (depth-1 children)
        local roots = {
          vim.fn.expand("~/projects/github.com/hyperledger"),
          vim.fn.expand("~/projects/github.ibm.com"),
        }

        local projects = {}
        local seen = {}

        for _, root in ipairs(roots) do
          -- Collect immediate subdirectories
          local entries = vim.fn.globpath(root, "*", false, true)
          for _, entry in ipairs(entries) do
            if vim.fn.isdirectory(entry) == 1 then
              table.insert(projects, entry)
              seen[entry] = true

              -- Also collect git worktrees one level deeper (e.g. repo/worktrees/*)
              local wt_dir = entry .. "/worktrees"
              if vim.fn.isdirectory(wt_dir) == 1 then
                local wt_entries = vim.fn.globpath(wt_dir, "*", false, true)
                for _, wt in ipairs(wt_entries) do
                  if vim.fn.isdirectory(wt) == 1 and not seen[wt] then
                    table.insert(projects, wt)
                    seen[wt] = true
                  end
                end
              end
            end
          end
        end

        table.sort(projects)

        local home = vim.fn.expand("~")

        pickers
          .new({}, {
            prompt_title = "Switch Project",
            finder = finders.new_table({
              results = projects,
              entry_maker = function(entry)
                -- Show path relative to home
                local display = entry:gsub("^" .. vim.pesc(home), "~")
                return { value = entry, display = display, ordinal = display }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local path = selection.value

                -- Close cached Snacks terminals (same as worktree switch)
                for _, term in ipairs(Snacks.terminal.list()) do
                  term:close()
                end

                -- Check if explorer was open before switching and close it
                local explorers = Snacks.picker.get({ source = "explorer" })
                local explorer_open = #explorers > 0
                for _, picker in ipairs(explorers) do
                  picker:close()
                end

                -- Change directory and open a fresh buffer so LazyVim.root
                -- detects the new project (lazygit uses root.git()).
                vim.cmd("cd " .. vim.fn.fnameescape(path))
                vim.cmd("enew")
                vim.notify("Switched to " .. path:match("[^/]+$"), vim.log.levels.INFO)

                -- Reopen explorer if it was open (fresh instance for new cwd)
                if explorer_open then
                  Snacks.explorer()
                end
              end)
              return true
            end,
          })
          :find()
      end,
      desc = "Switch project",
    },
  },
}
