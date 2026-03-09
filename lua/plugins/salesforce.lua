return {
  {
    "xixiaofinland/sf.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "ibhagwan/fzf-lua",
    },
    config = function()
      require("sf").setup()

      -- all your key definitions put below
      local Sf = require("sf")
      vim.keymap.set("n", "<leader>sfr", Sf.retrieve, { desc = "(Salesforce) Retrieve From Target Org" })
      vim.keymap.set("n", "<leader>sfp", Sf.save_and_push, { desc = "(Salesforce) Save And Push To Target Org" })
      vim.keymap.set("n", "<leader>sfs", Sf.set_target_org, { desc = "(Salesforce) set local" })
      vim.keymap.set("n", "<leader>sfS", Sf.set_global_target_org, { desc = "(Salesforce) set global" })
      vim.keymap.set("n", "<leader>sfl", Sf.set_target_org, { desc = "(Salesforce) List orgs" })

      -- Kill process on OAuth port 1717 (use after closing browser to fix "port in use" on next login)
      vim.keymap.set("n", "<leader>sfk", function()
        local pids = vim.fn.system("lsof -ti :1717 2>/dev/null"):gsub("%s+", "")
        if pids ~= "" then
          vim.fn.system("kill -9 " .. pids .. " 2>/dev/null")
          vim.notify("Killed process(es) on port 1717", vim.log.levels.INFO, { title = "Salesforce" })
        else
          vim.notify("Nothing running on port 1717", vim.log.levels.INFO, { title = "Salesforce" })
        end
      end, { desc = "(Salesforce) Kill OAuth port 1717" })

      -- Org auth: select Login or Test (sandbox), then run web login in terminal
      vim.keymap.set("n", "<leader>sfa", function()
        vim.ui.select({ "Login", "Test" }, {
          prompt = "Org login:",
          format_item = function(item)
            return item == "Login" and "Login (production)" or "Test (sandbox)"
          end,
        }, function(choice)
          if not choice then return end
          local use_sf = vim.fn.executable("sf") == 1
          local cmd
          if choice == "Login" then
            cmd = use_sf and "sf org login web" or "sfdx force:auth:web:login"
          else
            cmd = use_sf and "sf org login web --instance-url https://test.salesforce.com" or "sfdx force:auth:web:login -r https://test.salesforce.com"
          end
          vim.cmd("tabnew | terminal " .. cmd)
          vim.schedule(function()
            pcall(vim.api.nvim_buf_set_name, 0, "Salesforce Login Terminal")
          end)
        end)
      end, { desc = "(Salesforce) Org login (web)" })
    end,
  },
}
