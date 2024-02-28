local api = vim.api

local function open_terminal_and_run_command(command)
  vim.cmd "terminal" -- Open the terminal window
  api.nvim_command("term exec " .. command) -- Execute the command
end

-- Press Shift+F11 to run python3.10 <filename.py>
-- This shortcut is only available to python3
vim.keymap.set("n", "<S-F11>", function()
  local filename = api.nvim_buf_get_name(0)
  -- local project_path = get_project_path()
  local cmd = "python3.10 " .. filename
  open_terminal_and_run_command(cmd)
end, {
  noremap = true, -- Optional, prevents conflicting mappings
})

-- Lazy shift finger commands
api.nvim_create_user_command("W", "write", {})
api.nvim_create_user_command("Wa", "wa", {})
api.nvim_create_user_command("WA", "wa", {})
api.nvim_create_user_command("Wq", "wq", {})
api.nvim_create_user_command("WQ", "wq", {})
api.nvim_create_user_command("Wqa", "wqa", {})
api.nvim_create_user_command("WQa", "wqa", {})
api.nvim_create_user_command("Q", "quit", {})
api.nvim_create_user_command("QA", "quitall", {})
api.nvim_create_user_command("Qa", "quitall", {})

vim.api.nvim_set_keymap("n", "<leader>df", ":!black .<CR>", { noremap = true, silent = true })

