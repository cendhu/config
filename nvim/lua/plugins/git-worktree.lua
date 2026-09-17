return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local Hooks = require("git-worktree.hooks")
    Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)
    Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
      -- Defer so Telescope/picker fully closes before we manipulate windows
      vim.schedule(function()
        -- Close explorer before switching so it reopens fresh for the new cwd
        local explorers = Snacks.picker.get({ source = "explorer" })
        local explorer_open = #explorers > 0
        for _, picker in ipairs(explorers) do
          picker:close()
        end
        vim.cmd("cd " .. vim.fn.fnamemodify(path, ":p"))
        -- Close cached Snacks terminals so lazygit reopens in the new worktree
        for _, term in ipairs(Snacks.terminal.list()) do
          term:close()
        end
        -- Reopen explorer if it was open before the switch (fresh instance for new cwd)
        if explorer_open then
          Snacks.explorer()
        end
      end)
    end)
    require("telescope").load_extension("git_worktree")
  end,
  keys = {
    {
      "<leader>gw",
      function()
        -- Use a custom picker that includes the main working tree,
        -- which git-worktree.nvim's telescope extension omits.
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local conf = require("telescope.config").values

        local output = vim.fn.systemlist("git worktree list --porcelain")
        local worktrees = {}
        local current_wt = nil
        for _, line in ipairs(output) do
          if line:match("^worktree ") then
            current_wt = { path = line:sub(10) }
          elseif line:match("^branch ") and current_wt then
            current_wt.branch = line:sub(8):match("[^/]+$")
            table.insert(worktrees, current_wt)
            current_wt = nil
          elseif line:match("^detached") and current_wt then
            current_wt.branch = "(detached)"
            table.insert(worktrees, current_wt)
            current_wt = nil
          end
        end

        local max_branch_len = 0
        for _, wt in ipairs(worktrees) do
          max_branch_len = math.max(max_branch_len, #wt.branch)
        end

        pickers
          .new({}, {
            prompt_title = "Git Worktrees",
            finder = finders.new_table({
              results = worktrees,
              entry_maker = function(entry)
                local branch = entry.branch
                -- Show path starting from fabric-x-committer
                local short_path = entry.path:match("(fabric%-x%-committer.*)") or entry.path
                -- Pad branch column to longest branch + 2 for clean alignment
                local pad = max_branch_len + 2
                local display = string.format("%-" .. pad .. "s %s", branch, short_path)
                return { value = entry, display = display, ordinal = branch .. " " .. short_path }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local path = selection.value.path
                local Hooks = require("git-worktree.hooks")
                local prev_path = vim.fn.getcwd()
                Hooks.emit(Hooks.type.SWITCH, path, prev_path)
              end)
              return true
            end,
          })
          :find()
      end,
      desc = "Switch git worktree",
    },
    {
      "<leader>gW",
      function()
        -- Resolve the main worktree root so telescope finds a real .git directory,
        -- not the .git file inside a worktree.
        local main_root = vim.fn.systemlist("git worktree list --porcelain")[1]:sub(10)
        require("telescope").extensions.git_worktree.create_git_worktree({ cwd = main_root, prefix = main_root .. "/worktrees/" })
      end,
      desc = "Create git worktree",
    },
  },
}
