-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt

opt.scrolloff = 25

opt.colorcolumn = "132"

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})

-- Map uppercase quit commands to lowercase (e.g. :Q -> :q, :QA/:Qa -> :qa)
vim.cmd("cnoreabbrev QA qa")
vim.cmd("cnoreabbrev Qa qa")
vim.cmd("cnoreabbrev Q q")
