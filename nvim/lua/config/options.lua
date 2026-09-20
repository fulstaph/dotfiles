-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Dedicated Neovim Python provider with pynvim & jupyter_client for notebooks
local py_venv = vim.fn.expand("~/.local/share/nvim/venv/bin/python3")
if vim.fn.filereadable(py_venv) == 1 then
  vim.g.python3_host_prog = py_venv
end
