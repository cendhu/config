return {
  "georgeguimaraes/review.nvim",
  dependencies = {
    "esmuellert/codediff.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = { "Review" },
  keys = {
    { "<leader>rv", "<cmd>Review<cr>", desc = "Review working changes" },
    { "<leader>rc", "<cmd>Review commits<cr>", desc = "Review commits" },
  },
  opts = {},
}
