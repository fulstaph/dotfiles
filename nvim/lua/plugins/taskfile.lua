return {
  {
    "fulstaph/taskfile.nvim",
    lazy = false,
    dependencies = { "folke/snacks.nvim" },
    opts = {},
    keys = {
      {
        "<leader>Tr",
        function()
          require("taskfile").pick(false, false)
        end,
        desc = "Run Task",
      },
      {
        "<leader>Ta",
        function()
          require("taskfile").pick(true, false)
        end,
        desc = "Run Task (all)",
      },
      {
        "<leader>Td",
        function()
          require("taskfile").pick(false, true)
        end,
        desc = "Dry-run Task",
      },
      {
        "<leader>Tl",
        function()
          require("taskfile").rerun()
        end,
        desc = "Rerun Last Task",
      },
      {
        "<leader>Te",
        function()
          require("taskfile").edit()
        end,
        desc = "Edit Taskfile",
      },
      {
        "<leader>Tc",
        function()
          require("taskfile").run_cursor()
        end,
        desc = "Run Task at Cursor",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>T", group = "taskfile", icon = " " },
      },
    },
  },
}
