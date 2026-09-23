-- Agent Lens: watch AI agent file edits in real-time
return {
  {
    "fulstaph/agent-lens.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>al", "<cmd>AgentLens<cr>", desc = "Toggle Agent Lens" },
      { "<leader>ad", "<cmd>AgentLensDiff<cr>", desc = "Agent Lens: Show Diff" },
      { "<leader>ac", "<cmd>AgentLensClear<cr>", desc = "Agent Lens: Clear Timeline" },
      { "<leader>af", "<cmd>AgentLensFollow<cr>", desc = "Agent Lens: Follow Agent" },
    },
    opts = {
      agent_name = "pi",
      timeline_position = "right",
      timeline_width = 42,
      debounce_ms = 150,
      auto_open_diff = false,
      reads = { enabled = true },
      inline = { enabled = true },
      follow = { enabled = true },
    },
    config = function(_, opts)
      require("agent-lens").setup(opts)
    end,
  },
}
