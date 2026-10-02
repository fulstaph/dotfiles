-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LazyVim reads these before plugin specs. Basedpyright for types; Ruff for lint/format.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Dedicated Python environment for Neovim's provider only. Do not prepend it to PATH:
-- project interpreters and ~/.local/bin/jupytext must stay ahead of the provider venv.
local py_venv = vim.fn.expand("~/.local/share/nvim/venv/bin/python3")
if vim.fn.filereadable(py_venv) == 1 then
  vim.g.python3_host_prog = py_venv
end
