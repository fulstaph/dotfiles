-- Agent Lens: watch AI agent file edits in real-time
return {
  {
    "fulstaph/agent-lens.nvim",
    tag = "v0.1.0",
    event = "VeryLazy",
    keys = {
      { "<leader>al", "<cmd>AgentLens<cr>", desc = "Toggle Agent Lens" },
      { "<leader>ad", "<cmd>AgentLensDiff<cr>", desc = "Agent Lens: Show Diff" },
      { "<leader>ac", "<cmd>AgentLensClear<cr>", desc = "Agent Lens: Clear Timeline" },
      { "<leader>af", "<cmd>AgentLensFollow<cr>", desc = "Agent Lens: Follow Agent" },
      { "<leader>ar", "<cmd>AgentLensResume<cr>", desc = "Agent Lens: Resume Following" },
      { "<leader>as", "<cmd>AgentLensStatus<cr>", desc = "Agent Lens: Status" },
      { "<leader>ap", "<cmd>AgentLensPreview<cr>", desc = "Agent Lens: Preview Hunk" },
    },
    opts = {
      agent_name = "pi",
      timeline_position = "right",
      timeline_width = 42,
      debounce_ms = 150,
      auto_open_diff = false,
      reads = { enabled = true },
      inline = { enabled = true },
      follow = { enabled = true, preview = true, animation = true, animation_ms = 180 },
    },
    config = function(_, opts)
      require("agent-lens").setup(opts)
    end,
  },
}
