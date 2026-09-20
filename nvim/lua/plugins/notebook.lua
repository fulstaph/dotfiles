return {
  -- 1. Jupytext: transparently edit .ipynb notebooks as Python (# %% cells)
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "percent",
      output_extension = "auto",
      force_ft = "python",
      custom_language_formatting = {
        python = {
          extension = "py",
          style = "percent",
          force_ft = "python",
        },
      },
    },
  },

  -- 2. Molten: interactive Jupyter notebook kernel runner
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    cmd = {
      "MoltenInit",
      "MoltenDeinit",
      "MoltenEvaluateLine",
      "MoltenEvaluateVisual",
      "MoltenReevaluateCell",
      "MoltenRestart",
      "MoltenInterrupt",
      "MoltenShowOutput",
      "MoltenHideOutput",
      "MoltenDelete",
      "MoltenExportOutput",
    },
    init = function()
      -- Output display options
      vim.g.molten_image_provider = "none"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_output_win_max_width = 100
      vim.g.molten_output_win_cover_gutter = false
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_wrap_output = true
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Initialize Kernel" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Run Current Cell" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Run Current Line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Run Visual Selection" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete Cell Output" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show Output Window" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide Output Window" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt Kernel" },
      { "<leader>jR", "<cmd>MoltenRestart<cr>", desc = "Restart Kernel" },
      {
        "<leader>jc",
        function()
          vim.cmd("MoltenReevaluateCell")
          -- Jump forward to next cell if found
          vim.fn.search("^# %%%%", "W")
        end,
        desc = "Run Cell and Advance",
      },
      {
        "]c",
        function()
          vim.fn.search("^# %%%%", "W")
        end,
        desc = "Next Notebook Cell",
      },
      {
        "[c",
        function()
          vim.fn.search("^# %%%%", "bW")
        end,
        desc = "Previous Notebook Cell",
      },
    },
  },

  -- 3. Register key group in which-key
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>j", group = "jupyter / notebook", icon = "󰠮 " },
      },
    },
  },
}
