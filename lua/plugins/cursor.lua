-- Persistent list of buffer IDs for local background agents (survives across config reloads)
local background_agent_buffers = {}

return {
  {
    "bka9/cursor.nvim",
    event = "VeryLazy",
    opts = {
      cmd = "agent",
      parameters = {},
      extra_args = {},
      -- set to true to start agent in Cloud mode (runs on Cursor's servers, continue at cursor.com/agents)
      cloud = false,
      -- "float" = floating window (default), "tab" = new tab, "split" = horizontal split, "vsplit" = vertical split
      window = {
        type = "tab",
        width = 0.6,
        height = 0.6,
        border = "rounded",
        position = "bottom",
        focus = true,
      },
      start_in_insert = true,
      auto_close_on_exit = false,
      disable_default_keymaps = true, -- we set co/cf/cp ourselves so <leader>cp works with our tab terminals
    },
    keys = {
      { "<leader>co", "<cmd>CursorAgentOpen<cr>", desc = "Cursor: open agent (tab)" },
      { "<leader>cf", "<cmd>CursorAgentFocusBuffer<cr>", desc = "Cursor: focus agent terminal" },
      { "<leader>cp", "<cmd>CursorAgentPromptSend<cr>", desc = "Cursor: prompt and send to agent" },
      { "<leader>cl", "<cmd>CursorAgentList<cr>", desc = "Cursor: list sessions" },
      { "<leader>cc", "<cmd>CursorAgentCloud<cr>", desc = "Cursor: run agent in cloud (background)" },
      { "<leader>cB", "<cmd>CursorAgentBackground<cr>", desc = "Cursor: run agent in local background" },
      { "<leader>cr", "<cmd>CursorAgentContinue<cr>", desc = "Cursor: continue a background agent" },
      { "<leader>cR", "<cmd>CursorAgentResume<cr>", desc = "Cursor: resume last saved session" },
      { "<leader>ct", "<cmd>CursorAgentFocusBuffer<cr>", desc = "Cursor: go to agent terminal buffer" },
    },
    config = function(_, opts)
      if opts.cloud then
        opts.extra_args = vim.list_extend(opts.extra_args or {}, { "-c" })
      end
      opts.cloud = nil
      require("cursor_agent").setup(opts)

      -- Escape twice to exit terminal mode (any terminal buffer)
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

      local cmd = opts.cmd or "agent"
      local win_type = (opts.window and opts.window.type) or "float"

      -- Ubuntu-style codenames for agent tab names; counter cycles through and guarantees uniqueness
      local agent_tab_counter = 0
      local codenames = { "Raccoon", "Lion", "Fox", "Owl", "Bear", "Wolf", "Hawk", "Eagle", "Falcon", "Lynx" }

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

      -- Show buffer in a window according to window.type (float | tab | split | vsplit)
      -- For "tab": plugin already created a tab; just use current window to avoid two tabs.
      local function show_buf_in_window(buf)
        if win_type == "tab" then
          vim.api.nvim_win_set_buf(0, buf)
        elseif win_type == "split" then
          vim.cmd.split()
          vim.api.nvim_win_set_buf(0, buf)
        elseif win_type == "vsplit" then
          vim.cmd.vsplit()
          vim.api.nvim_win_set_buf(0, buf)
        else
          vim.api.nvim_open_win(buf, true, float_dims())
        end
      end

      local function open_cursor_float(agent_args, name, opts_override)
        opts_override = opts_override or {}
        if vim.fn.executable(cmd) == 0 then
          vim.notify("Cursor: " .. cmd .. " not found in PATH", vim.log.levels.ERROR)
          return
        end
        local buf = vim.api.nvim_create_buf(false, true)
        show_buf_in_window(buf)
        vim.fn.termopen(vim.list_extend({ cmd }, agent_args), {
          on_exit = function(_, code)
            if code ~= 0 and code ~= 143 then
              vim.schedule(function()
                vim.notify(name .. " exited with code " .. code, vim.log.levels.WARN)
              end)
            end
          end,
        })
        -- In tab/split mode keep buffer so you can switch back; float uses wipe when closed.
        local keep_buf = (win_type == "tab" or win_type == "split" or win_type == "vsplit")
        vim.bo[buf].bufhidden = opts_override.bufhidden or (keep_buf and "hide" or "wipe")
        if keep_buf then
          vim.bo[buf].buflisted = true
          vim.api.nvim_buf_set_name(buf, "cursor-agent://" .. (name or "terminal"))
        end
        if opts_override.on_buf_created then
          opts_override.on_buf_created(buf)
        end
        vim.cmd.startinsert()
      end

      -- Start a **local** background agent: close the window (Esc Esc then :q!) to hide; process may keep running if buf stays; use CursorAgentContinue to reopen
      local function open_cursor_float_background()
        if vim.fn.executable(cmd) == 0 then
          vim.notify("Cursor: " .. cmd .. " not found in PATH", vim.log.levels.ERROR)
          return
        end
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].bufhidden = "hide"
        vim.bo[buf].buflisted = true
        vim.api.nvim_buf_set_name(buf, "cursor-agent-background://" .. tostring(buf))
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
        show_buf_in_window(buf)
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

      -- Reopen a background agent buffer in a window (same type as configured)
      local function open_buf_in_window(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          vim.notify("Cursor: that buffer is no longer valid", vim.log.levels.WARN)
          return
        end
        show_buf_in_window(buf)
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

      -- Continue a local background agent: pick one and reopen its window.
      -- Also discovers buffers marked as background (e.g. after config reload).
      vim.api.nvim_create_user_command("CursorAgentContinue", function()
        local seen = {}
        local valid = {}
        for _, buf in ipairs(background_agent_buffers) do
          if vim.api.nvim_buf_is_valid(buf) and not seen[buf] then
            seen[buf] = true
            table.insert(valid, buf)
          end
        end
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and not seen[buf] then
            local ok, _ = pcall(function()
              return vim.api.nvim_buf_get_var(buf, "cursor_agent_background")
            end)
            if ok and vim.bo[buf].buftype == "terminal" then
              seen[buf] = true
              table.insert(valid, buf)
              table.insert(background_agent_buffers, buf)
            end
          end
        end
        background_agent_buffers = valid
        if #valid == 0 then
          vim.notify(
            "Cursor: no background agent windows. Use <leader>cB to start one, or <leader>cR to resume last saved session.",
            vim.log.levels.INFO
          )
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
            open_buf_in_window(selected.value)
          end
        end)
      end, { desc = "Continue a local background Cursor agent" })

      -- Resume the last saved Cursor session from disk (survives Neovim restart)
      vim.api.nvim_create_user_command("CursorAgentResume", function()
        open_cursor_float({ "resume" }, "cursor-agent resume")
      end, { desc = "Resume last saved Cursor agent session (from disk)" })

      -- Go to Cursor agent terminal buffer (when opened in tab/split so it stays in buffer list)
      vim.api.nvim_create_user_command("CursorAgentFocusBuffer", function()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "terminal" then
            local name = vim.api.nvim_buf_get_name(b)
            if name and name:match("^cursor%-agent://") then
              vim.api.nvim_win_set_buf(0, b)
              vim.cmd.startinsert()
              return
            end
          end
        end
        vim.notify("Cursor: no agent terminal buffer. Use <leader>co or <leader>cR to start one.", vim.log.levels.INFO)
      end, { desc = "Switch to Cursor agent terminal buffer" })

      -- Prompt and send to agent: find a cursor-agent terminal by buffer name (works with our tab terminals;
      -- plugin's built-in prompt_and_send uses internal state which we don't set when opening tabs).
      vim.api.nvim_create_user_command("CursorAgentPromptSend", function()
        local function job_active(job_id)
          if not job_id or job_id == 0 then return false end
          local res = vim.fn.jobwait({ job_id }, 0)
          return res[1] == -1
        end
        local function find_agent_buf_and_job()
          local cur_buf = vim.api.nvim_get_current_buf()
          local cur_name = vim.api.nvim_buf_get_name(cur_buf)
          if vim.bo[cur_buf].buftype == "terminal" and cur_name and cur_name:match("^cursor%-agent://") then
            local job_id = vim.bo[cur_buf].channel
            if job_active(job_id) then return cur_buf, job_id end
          end
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "terminal" then
              local name = vim.api.nvim_buf_get_name(b)
              if name and name:match("^cursor%-agent://") then
                local job_id = vim.bo[b].channel
                if job_active(job_id) then return b, job_id end
              end
            end
          end
          return nil, nil
        end
        local buf, job_id = find_agent_buf_and_job()
        if not buf or not job_id then
          require("cursor_agent").open()
          buf = vim.api.nvim_get_current_buf()
          job_id = vim.bo[buf].channel
          if not job_id or not job_active(job_id) then
            vim.notify("Cursor: agent terminal is not available. Use <leader>co to start one.", vim.log.levels.ERROR)
            return
          end
        end
        vim.ui.input({ prompt = "Cursor prompt: " }, function(input)
          if not input or input == "" then return end
          local payload = input:match("\n$") and input or (input .. "\n")
          vim.api.nvim_chan_send(job_id, payload)
          -- Focus the agent window so user sees the response
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf then
              vim.api.nvim_set_current_win(win)
              if opts.start_in_insert then vim.cmd.startinsert() end
              break
            end
          end
        end)
      end, { desc = "Prompt and send to Cursor agent terminal" })

      -- Plugin only supports float | horizontal | vertical | current; "tab" falls through to "current" and replaces your buffer.
      -- Override so :CursorAgentOpen / <leader>co open in a new tab when type is "tab".
      if win_type == "tab" then
        require("cursor_agent").open = function()
          agent_tab_counter = agent_tab_counter + 1
          local name = codenames[((agent_tab_counter - 1) % #codenames) + 1]
          open_cursor_float({}, ("Cursor %s %d"):format(name, agent_tab_counter), {})
        end
      end
    end,
  },
}
