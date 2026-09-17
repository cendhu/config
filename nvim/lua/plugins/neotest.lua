return {
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      ["neotest-golang"] = {
        go_test_args = { "-v", "-count=1", "-timeout=15m" },
        dap_go_enabled = true,
      },
    },
  },
}
