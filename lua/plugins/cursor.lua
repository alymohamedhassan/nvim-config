-- Persistent list of buffer IDs for local background agents (survives across config reloads)
local background_agent_buffers = {}

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
      { "<leader>cB", "<cmd>CursorAgentBackground<cr>", desc = "Cursor: run agent in local background" },
      { "<leader>cr", "<cmd>CursorAgentContinue<cr>", desc = "Cursor: continue a background agent" },
    },
    config = function(_, opts)
      if opts.cloud then
        opts.extra_args = vim.list_extend(opts.extra_args or {}, { "-c" })
      end
      opts.cloud = nil
      require("cursor_agent").setup(opts)

      -- Escape twice to exit terminal mode (any terminal buffer)
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

      local cmd = opts.cmd or "cursor-agent"

      local function float_dims()
        local width = math.floor(vim.o.columns * 0.6)
        local height = math.floor(vim.o.lines * 0.6)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)
        return {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        }
      end

      local function open_cursor_float(agent_args, name, opts_override)
        opts_override = opts_override or {}
        if vim.fn.executable(cmd) == 0 then
          vim.notify("Cursor: " .. cmd .. " not found in PATH", vim.log.levels.ERROR)
          return
        end
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_open_win(buf, true, float_dims())
        vim.fn.termopen(vim.list_extend({ cmd }, agent_args), {
          on_exit = function(_, code)
            if code ~= 0 and code ~= 143 then
              vim.schedule(function()
                vim.notify(name .. " exited with code " .. code, vim.log.levels.WARN)
              end)
            end
          end,
        })
        vim.bo[buf].bufhidden = opts_override.bufhidden or "wipe"
        if opts_override.on_buf_created then
          opts_override.on_buf_created(buf)
        end
        vim.cmd.startinsert()
      end

      -- Start a **local** background agent: close the window and the process keeps running; use CursorAgentContinue to reopen
      local function open_cursor_float_background()
        if vim.fn.executable(cmd) == 0 then
          vim.notify("Cursor: " .. cmd .. " not found in PATH", vim.log.levels.ERROR)
          return
        end
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].bufhidden = "hide"
        pcall(vim.api.nvim_buf_set_var, buf, "cursor_agent_background", true)
        table.insert(background_agent_buffers, buf)
        vim.api.nvim_create_autocmd("BufDelete", {
          buffer = buf,
          once = true,
          callback = function()
            for i, b in ipairs(background_agent_buffers) do
              if b == buf then
                table.remove(background_agent_buffers, i)
                break
              end
            end
          end,
        })
        vim.api.nvim_open_win(buf, true, float_dims())
        vim.fn.termopen({ cmd }, {
          on_exit = function(_, code)
            if code ~= 0 and code ~= 143 then
              vim.schedule(function()
                vim.notify("Cursor background agent exited with code " .. code, vim.log.levels.WARN)
              end)
            end
          end,
        })
        vim.cmd.startinsert()
      end

      -- Reopen a background agent buffer in a float
      local function open_buf_in_float(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          vim.notify("Cursor: that buffer is no longer valid", vim.log.levels.WARN)
          return
        end
        vim.api.nvim_open_win(buf, true, float_dims())
      end

      -- List sessions: open a floating terminal running `cursor-agent ls` (interactive)
      vim.api.nvim_create_user_command("CursorAgentList", function()
        open_cursor_float({ "ls" }, "cursor-agent ls")
      end, { desc = "List Cursor agent sessions (interactive)" })

      -- Run agent in Cloud (background): continues at cursor.com/agents when you close the terminal
      vim.api.nvim_create_user_command("CursorAgentCloud", function()
        open_cursor_float({ "-c" }, "Cursor Cloud Agent")
      end, { desc = "Run Cursor agent in cloud (background)" })

      -- Run agent in local background: close window to hide; process keeps running
      vim.api.nvim_create_user_command("CursorAgentBackground", function()
        open_cursor_float_background()
      end, { desc = "Run Cursor agent in local background (close window to hide, continue with CursorAgentContinue)" })

      -- Continue a local background agent: pick one and reopen its window
      vim.api.nvim_create_user_command("CursorAgentContinue", function()
        local valid = {}
        for _, buf in ipairs(background_agent_buffers) do
          if vim.api.nvim_buf_is_valid(buf) then
            table.insert(valid, buf)
          end
        end
        background_agent_buffers = valid
        if #valid == 0 then
          vim.notify("Cursor: no background agents running. Use CursorAgentBackground first.", vim.log.levels.INFO)
          return
        end
        local items = {}
        for _, buf in ipairs(valid) do
          table.insert(items, { value = buf, label = ("Agent (buffer %d)"):format(buf) })
        end
        vim.ui.select(items, {
          prompt = "Continue background agent",
          format_item = function(item)
            return item.label
          end,
        }, function(selected)
          if selected then
            open_buf_in_float(selected.value)
          end
        end)
      end, { desc = "Continue a local background Cursor agent" })
    end,
  },
}
