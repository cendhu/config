-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable format-on-save for YAML files (LSP formatting conflicts with yamllint)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yaml.docker-compose" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Associate Go template files with gotmpl filetype for Tree-sitter highlighting
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
    tmpl = "gotmpl",
  },
  pattern = {
    -- Files like foo.html.tmpl, foo.yaml.tmpl, etc.
    [".*%.tmpl"] = "gotmpl",
  },
})

-- Disable gopls semantic tokens for Go template files so Tree-sitter highlighting is preserved
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("gotmpl_disable_semantic_tokens", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "gotmpl" then
      return
    end
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "gopls" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

-- Auto-detect file changes and prompt to reload
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  pattern = "*",
  command = "checktime",
})
