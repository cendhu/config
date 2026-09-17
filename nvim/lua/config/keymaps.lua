-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Toggle inlay hints (useful for Go parameter names)
map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })

-- Quick buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Keep cursor centered when searching
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste without losing register content
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- Find Go struct tag references for YAML key under cursor
-- Works in YAML files: cursor on a key, press <leader>gy to find matching Go struct tags
map("n", "<leader>gy", function()
  -- Use <cWORD> to capture hyphenated keys like "waiting-txs-limit", strip trailing ":"
  local word = vim.fn.expand("<cWORD>"):gsub("[:%s]+$", "")
  if word == "" then
    return
  end
  -- Search for mapstructure/yaml/json tags or raw word in Go files
  require("snacks").picker.grep({
    search = [[mapstructure:"]] .. word .. [["|yaml:"]] .. word .. [["|json:"]] .. word .. [["|"]] .. word .. [["]],
    glob = "*.go",
  })
end, { desc = "Find Go struct tag for YAML key" })

-- Quick save
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Toggle soft wrap at 121 columns
local wrap121_active = false
local saved_columns = nil
map("n", "<leader>uw", function()
  if wrap121_active then
    vim.opt.wrap = false
    vim.opt.linebreak = false
    if saved_columns then
      vim.opt.columns = saved_columns
      saved_columns = nil
    end
    wrap121_active = false
    vim.notify("Wrap 121 OFF")
  else
    saved_columns = vim.o.columns
    vim.opt.columns = 121
    vim.opt.wrap = true
    vim.opt.linebreak = true
    wrap121_active = true
    vim.notify("Wrap 121 ON")
  end
end, { desc = "Toggle Wrap at 121 columns" })
