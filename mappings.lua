local M = {}

-- In order to disable a default keymap, use
M.disabled = {
  n = {
      ["<leader>h"] = "",
      ["<C-a>"] = "",
      ["gi"] = ""
  }
}

M.general = {
  i = {
    -- ["lkj"] = {"<ESC>", "Escape insert mode", opts={nowait=true}},
    ["<C-z>"] = {"<ESC>ui", "Undo", opts={nowait=true}},
    ["<C-y>"] = {"<ESC><C-r>i", "Redo", opts={nowait=true}},
    ["<C-v>"] = {"<ESC>pa", "Paste with Ctrl-v in insert mode"},
    ["<C-c>"] = {"<ESC>yiwi", "Paste with Ctrl-v in insert mode"},
  },
  n = {
    ["<A-k>"] = {"yyP", "Copy this line once up", opts={nowait=true}},
    ["<A-j>"] = {"yyp", "Copy this line once down", opts={nowait=true}},
    ["<C-k>"] = {"ddkP", "Move this line one line up", opts={nowait=true}},
    ["<C-j>"] = {"ddp", "Move this line one line down", opts={nowait=true}},
    -- ["k<CR>"] = {"O<ESC>", "Create an empty line above", opts={nowait=true}},
    ["<CR>"] = {"o<ESC>", "Create an empty line below", opts={nowait=true}},
    ["<leader><CR>"] = {"O<ESC>", "Create an empty line below", opts={nowait=true}},
    ["<C-z>"] = {"u", "Undo", opts={nowait=true}},

    -- -- Go To Custom Menu
    -- ["gi"] = {"", "~go to section",},
    -- ["gii"] = {"gi", "go to last insertion and insert", opts={nowait=true}},
    -- ["gi{"] = {"ci{", "go to last insertion and insert", opts={nowait=true}},
  },
  v = {
    -- ["<A-k>"] = {"dkPgv", "Move Up"},
    -- ["<A-j>"] = {"dpgv", "Move Up"},
  },
}

return M
