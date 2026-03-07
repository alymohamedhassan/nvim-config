return {
  {
    "bka9/cursor.nvim",
    event = "VeryLazy",
    opts = {
      cmd = "cursor-agent",
      parameters = {},
      extra_args = {},
      -- set to true to start agent in Cloud mode (runs on Cursor's servers, continue at cursor.com/agents)
      cloud = false,
      window = {
        type = "float",
        width = 0.6,
        height = 0.6,
        border = "rounded",
        position = "bottom",
        focus = true,
      },
      start_in_insert = true,
      auto_close_on_exit = false,
      disable_default_keymaps = false,
    },
    keys = {
      { "<leader>cl", "<cmd>CursorAgentList<cr>", desc = "Cursor: list sessions" },
      { "<leader>cc", "<cmd>CursorAgentCloud<cr>", desc = "Cursor: run agent in cloud (background)" },
    },
    config = function(_, opts)
      if opts.cloud then
        opts.extra_args = vim.list_extend(opts.extra_args or {}, { "-c" })
      end
      opts.cloud = nil
      require("cursor_agent").setup(opts)

      local cmd = opts.cmd or "cursor-agent"

      local function open_cursor_float(agent_args, name)
        if vim.fn.executable(cmd) == 0 then
          vim.notify("Cursor: " .. cmd .. " not found in PATH", vim.log.levels.ERROR)
          return
        end
        local width = math.floor(vim.o.columns * 0.6)
        local height = math.floor(vim.o.lines * 0.6)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)
        local win_opts = {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        }
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_open_win(buf, true, win_opts)
        vim.fn.termopen(vim.list_extend({ cmd }, agent_args), {
          on_exit = function(_, code)
            if code ~= 0 and code ~= 143 then
              vim.schedule(function()
                vim.notify(name .. " exited with code " .. code, vim.log.levels.WARN)
              end)
            end
          end,
        })
        vim.bo[buf].bufhidden = "wipe"
        vim.cmd.startinsert()
      end

      -- List sessions: open a floating terminal running `cursor-agent ls` (interactive)
      vim.api.nvim_create_user_command("CursorAgentList", function()
        open_cursor_float({ "ls" }, "cursor-agent ls")
      end, { desc = "List Cursor agent sessions (interactive)" })

      -- Run agent in Cloud (background): continues at cursor.com/agents when you close the terminal
      vim.api.nvim_create_user_command("CursorAgentCloud", function()
        open_cursor_float({ "-c" }, "Cursor Cloud Agent")
      end, { desc = "Run Cursor agent in cloud (background)" })
    end,
  },
}
