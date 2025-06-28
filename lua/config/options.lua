-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt

opt.scrolloff = 25

opt.colorcolumn = "120"

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})
