local MARKDOWN_CELL_MARKER = "# %% [markdown]"

local function is_cell_marker(line)
  return line ~= nil and line:sub(1, 4) == "# %%"
end

local function current_cell_bounds()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local first_line = vim.api.nvim_win_get_cursor(0)[1]

  while first_line > 0 and not is_cell_marker(lines[first_line]) do
    first_line = first_line - 1
  end

  if first_line == 0 then
    vim.notify("Cursor is not in a Jupytext cell", vim.log.levels.WARN)
    return
  end

  if lines[first_line]:sub(1, #MARKDOWN_CELL_MARKER) == MARKDOWN_CELL_MARKER then
    vim.notify("Markdown cells cannot be executed", vim.log.levels.INFO)
    return
  end

  local next_line = first_line + 1
  while next_line <= #lines and not is_cell_marker(lines[next_line]) do
    next_line = next_line + 1
  end

  return first_line, next_line - 1, next_line <= #lines and next_line or nil
end

local function run_current_cell(advance)
  local first_line, last_line, next_cell = current_cell_bounds()
  if not first_line then
    return
  end

  vim.fn.MoltenEvaluateRange(first_line, last_line)
  if advance and next_cell then
    vim.api.nvim_win_set_cursor(0, { next_cell, 0 })
  end
end

local function move_to_cell(direction)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line = vim.api.nvim_win_get_cursor(0)[1] + direction

  while line >= 1 and line <= #lines do
    if is_cell_marker(lines[line]) then
      vim.api.nvim_win_set_cursor(0, { line, 0 })
      return
    end
    line = line + direction
  end
end

local function create_notebook(path)
  local notebook_path = vim.fn.fnamemodify(path, ":p")
  if not notebook_path:match("%.ipynb$") then
    notebook_path = notebook_path .. ".ipynb"
  end

  if vim.fn.filereadable(notebook_path) == 1 or vim.fn.isdirectory(notebook_path) == 1 then
    vim.notify("Notebook already exists: " .. notebook_path, vim.log.levels.ERROR)
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(notebook_path, ":h"), "p")
  local notebook = {
    cells = {
      {
        cell_type = "code",
        execution_count = vim.NIL,
        id = "python-cell",
        metadata = vim.empty_dict(),
        outputs = {},
        source = { "" },
      },
    },
    metadata = {
      kernelspec = {
        display_name = "Python (Neovim)",
        language = "python",
        name = "neovim-python",
      },
      language_info = { name = "python" },
    },
    nbformat = 4,
    nbformat_minor = 5,
  }

  local result = vim.fn.writefile({ vim.json.encode(notebook) }, notebook_path)
  if result ~= 0 then
    vim.notify("Could not create notebook: " .. notebook_path, vim.log.levels.ERROR)
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(notebook_path))
end

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
      vim.api.nvim_create_user_command("NewPythonNotebook", function(opts)
        create_notebook(opts.args)
      end, {
        nargs = 1,
        complete = "file",
        desc = "Create a Python notebook",
      })
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Initialize Kernel" },
      {
        "<leader>jr",
        function()
          run_current_cell(false)
        end,
        ft = "python",
        desc = "Run Current Cell",
      },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Run Current Line" },
      {
        "<leader>jv",
        ":<C-u>MoltenEvaluateVisual<cr>gv",
        mode = "v",
        ft = "python",
        desc = "Run Visual Selection",
      },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete Cell Output" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show Output Window" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide Output Window" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt Kernel" },
      { "<leader>jR", "<cmd>MoltenRestart<cr>", desc = "Restart Kernel" },
      { "<leader>jE", "<cmd>MoltenExportOutput<cr>", desc = "Export Notebook Outputs" },
      {
        "<leader>jc",
        function()
          run_current_cell(true)
        end,
        ft = "python",
        desc = "Run Cell and Advance",
      },
      {
        "<leader>j[",
        function()
          move_to_cell(-1)
        end,
        ft = "python",
        desc = "Previous Notebook Cell",
      },
      {
        "<leader>j]",
        function()
          move_to_cell(1)
        end,
        ft = "python",
        desc = "Next Notebook Cell",
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
