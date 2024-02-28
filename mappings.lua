local M = {}

-- In order to disable a default keymap, use
M.disabled = {
  n = {
    ["<leader>h"] = "",
    ["<C-a>"] = "",
    ["gi"] = "",
  },
}

M.general = {
  i = {
    -- ["lkj"] = {"<ESC>", "Escape insert mode", opts={nowait=true}},
    ["<C-z>"] = { "<ESC>ui", "Undo", opts = { nowait = true } },
    ["<C-y>"] = { "<ESC><C-r>i", "Redo", opts = { nowait = true } },
    ["<C-v>"] = { "<ESC>pa", "Paste with Ctrl-v in insert mode" },
    ["<C-c>"] = { "<ESC>yiwi", "Paste with Ctrl-v in insert mode" },
  },
  n = {
    ["<A-k>"] = { "yyP", "Copy this line once up", opts = { nowait = true } },
    ["<A-j>"] = { "yyp", "Copy this line once down", opts = { nowait = true } },
    ["<C-k>"] = { "ddkP", "Move this line one line up", opts = { nowait = true } },
    ["<C-j>"] = { "ddp", "Move this line one line down", opts = { nowait = true } },
    -- ["k<CR>"] = {"O<ESC>", "Create an empty line above", opts={nowait=true}},
    ["<CR>"] = { "o<ESC>", "Create an empty line below", opts = { nowait = true } },
    ["<leader><CR>"] = { "O<ESC>", "Create an empty line below", opts = { nowait = true } },
    ["<C-z>"] = { "u", "Undo", opts = { nowait = true } },
    [";"] = { "A", "Easier insert mode after character", opts = { nowait = true } },

    ["VV"] = { "ggVG", "Select the whole file", opts = { nowait = true } },
    ["<C-a>"] = { "ggVG", "Select the whole file", opts = { nowait = true } },
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

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Run or continue the debugger",
    },
  },
}

return M
