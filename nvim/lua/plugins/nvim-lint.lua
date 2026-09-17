return {
  "mfussenegger/nvim-lint",
  event = "LazyFile",
  opts = {
    -- Event to trigger linters
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      go = { "golangcilint" },
      yaml = { "yamllint" },
      markdown = {}, -- override LazyVim markdown extra
      ["markdown.mdx"] = {}, -- override LazyVim markdown extra
    },
  },
}
