-- return {
--   "nvim-lspconfig",
--   opts = {
--     inlay_hints = { enabled = true },
--     servers = {
--       buf_ls = {
--         filetypes = { "proto" },
--       },
--     },
--   },
-- }
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = false,
              compositeLiteralFields = false,
              compositeLiteralTypes = false,
              constantValues = false,
              functionTypeParameters = false,
              parameterNames = false,
              rangeVariableTypes = false,
            },
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
            templateExtensions = { "tmpl", "gotmpl", "tpl" },
          },
        },
        filetypes = { "go", "gomod", "gowork", "gosum", "gotmpl" },
      },
    },
    setup = {
      gopls = function(_, opts)
        -- workaround for gopls not supporting semanticTokensProvider
        -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
          if not client.server_capabilities.semanticTokensProvider then
            local semantic = (client.config.capabilities.textDocument or {}).semanticTokens
            if not semantic then
              return
            end
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              legend = {
                tokenTypes = semantic.tokenTypes,
                tokenModifiers = semantic.tokenModifiers,
              },
              range = true,
            }
          end
        end)
        -- end workaround
      end,
    },
  },
}
