return {
  {
    "coder/claudecode.nvim",
    opts = function(_, opts)
      -- The Claude IDE server is intentionally long-lived; keep CI smoke tests
      -- finite while preserving auto-start for normal interactive sessions.
      if vim.env.CI == "true" then
        opts.auto_start = false
      end
    end,
  },
}
