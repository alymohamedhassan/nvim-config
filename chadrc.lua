---@type ChadrcConfig
local M = {}

M.ui = {
  theme = 'rosepine',
  nvdash = {
    load_on_startup = true,
  },
  statusline = {
    theme = "vscode_colored",
  },
  telescope = {
    style = "bordered",
  },
}
M.plugins = "custom.plugins"
M.mappings = require("custom.mappings")

return M
