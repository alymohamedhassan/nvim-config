-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local map = vim.keymap.set

-- NVChad Default
map("n", "<Tab>", ":bnext<CR>", { desc = "Next Tab" })
map("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous Tab" })
map("n", "<leader>x", "<leader>bd", { desc = "Close Tab" })

map("n", "<leader>x", "<leader>bd", { desc = "Close Tab" })

-- Comment
map("n", "<leader>c/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>c/", "gc", { desc = "toggle comment", remap = true })

-- Movement
map("n", "<C-c>", "VGy", { desc = "Copy the Whole File" })
map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
-- map("i", ";", "<End>", { desc = "move end of line", remap = true })
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
end, { desc = "whichkey query lookup" })

-- My Customizations

local M = {}

M.general = {
  i = {
    -- ["lkj"] = {"<ESC>", "Escape insert mode", opts={nowait=true}},
    ["<C-z>"] = { "<ESC>ui", "Undo", opts = { nowait = true } },
    ["<C-y>"] = { "<ESC><C-r>i", "Redo", opts = { nowait = true } },
    ["<C-v>"] = { "<ESC>pa", "Paste with Ctrl-v in insert mode" },
    ["<C-c>"] = { "<ESC>yiwi", "Paste with Ctrl-v in insert mode" },
  },
  n = {
    ["<Cmd-k>"] = { "ddkP", "Move this line one line up", opts = { nowait = true } },
    ["<Cmd-j>"] = { "ddp", "Move this line one line down", opts = { nowait = true } },
    -- ["k<CR>"] = {"O<ESC>", "Create an empty line above", opts={nowait=true}},
    ["<CR>"] = { "o<ESC>", "Create an empty line below", opts = { nowait = true } },
    ["<leader><CR>"] = { "O<ESC>", "Create an empty line below", opts = { nowait = true } },
    ["<C-z>"] = { "u", "Undo", opts = { nowait = true } },
    [";"] = { "A", "Easier insert mode after character", opts = { nowait = true } },

    ["VV"] = { "ggVG", "Select the whole file", opts = { nowait = true } },
    ["vv"] = { "ggVG", "Select the whole file", opts = { nowait = true } },
    ["<C-a>"] = { "ggVGy", "Select the whole file", opts = { nowait = true } },
    ["<C-v>"] = { "<ESC>p", "Paste with Ctrl-v" },
    ["<C-V>"] = { "<ESC>P", "Paste with Ctrl-v" },

    -- -- go to custom menu
    -- ["gi"] = {"", "~go to section",},
    -- ["gii"] = {"gi", "go to last insertion and insert", opts={nowait=true}},
    -- ["gi{"] = {"ci{", "go to last insertion and insert", opts={nowait=true}},
  },
  v = {
    -- ["<a-k>"] = {"dkpgv", "move up"},
    -- ["<a-j>"] = {"dpgv", "move up"},
  },
}

local keymap = vim.keymap.set

-- Function to apply mappings from a table for a given mode
local function apply_mappings(mode, mappings)
  for key, map in pairs(mappings) do
    -- Skip commented out mappings (those starting with -- in your table are not present)
    if map and type(map) == "table" then
      local cmd = map[1]
      local desc = map[2]
      local opts = map.opts or {}
      opts.desc = desc
      keymap(mode, key, cmd, opts)
    end
  end
end

-- Apply all mappings in M.general
for mode, mappings in pairs(M.general) do
  apply_mappings(mode, mappings)
end

-- at end-of-line: l → next line, col 1; else l
vim.keymap.set("n", "l", function()
  return (vim.fn.col(".") == vim.fn.col("$") - 1) and "j0" or "l"
end, { expr = true, noremap = true })

-- at start-of-line: h → prev line, last col; else h
vim.keymap.set("n", "h", function()
  return (vim.fn.col(".") == 1) and "k$" or "h"
end, { expr = true, noremap = true })

-- TODO: Move this to another file with all of the functions
local function go_to_char()
  -- Prompt user for a single character
  local char = vim.fn.nr2char(vim.fn.getchar())
  if char == "" then
    return
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  -- Search for the character after the current cursor position
  local start_pos = col + 2 -- Lua index is 1-based; col is 0-based
  local found_pos = line:find(char, start_pos, true)

  if found_pos then
    -- Move cursor to the found position (col is 0-based)
    vim.api.nvim_win_set_cursor(0, { row, found_pos - 1 })
  else
    print("Character '" .. char .. "' not found on this line after cursor")
  end
end

-- Map 'go' in normal mode to call the function and then wait for char
vim.keymap.set("n", "go", go_to_char, { desc = "Go to first occurrence of char after cursor" })

return M
