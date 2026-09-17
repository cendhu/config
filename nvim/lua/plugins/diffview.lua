local function toggle_diffview(cmd)
  local lib = require("diffview.lib")
  local view = lib.get_current_view()
  if view then
    vim.cmd("DiffviewClose")
  else
    vim.cmd(cmd)
  end
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gv", function() toggle_diffview("DiffviewOpen HEAD~1..HEAD") end, desc = "Diffview last commit" },
    { "<leader>gV", function() toggle_diffview("DiffviewOpen") end, desc = "Diffview working changes" },
    { "<leader>gh", function() toggle_diffview("DiffviewFileHistory %") end, desc = "Diffview file history" },
    { "<leader>gH", function() toggle_diffview("DiffviewFileHistory") end, desc = "Diffview branch history" },
  },
}
