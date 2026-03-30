-- Shared: resolve Salesforce project root (dir containing sfdx-project.json or sf-project.json)
local function sf_project_root()
  local cwd = vim.fn.getcwd()
  local dir = cwd
  for _ = 1, 20 do
    if vim.fn.filereadable(dir .. "/sfdx-project.json") == 1 or vim.fn.filereadable(dir .. "/sf-project.json") == 1 then
      return dir
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end
  return nil
end

-- Single source of truth: current org alias (set by refresh from CLI or when user picks org in DeployFromPackage)
local _sf_current_org_alias = ""
local _sf_org_statusline_cwd = ""

local function _sf_refresh_statusline_org(force)
  local cwd = vim.fn.getcwd()
  if not force and cwd == _sf_org_statusline_cwd then return end
  _sf_org_statusline_cwd = cwd
  local root = sf_project_root()
  if not root then
    _sf_current_org_alias = ""
    return
  end
  local use_sf = vim.fn.executable("sf") == 1
  local cmd = use_sf and "sf org display --json 2>/dev/null" or "sfdx force:org:display --json 2>/dev/null"
  local out = vim.fn.system("cd " .. vim.fn.shellescape(root) .. " && " .. cmd)
  local ok, data = pcall(vim.fn.json_decode, out)
  if ok and data and data.result then
    local r = data.result
    local alias = (r.alias and r.alias ~= "") and r.alias or r.username
    if type(alias) == "string" and alias ~= "" then
      _sf_current_org_alias = alias
    end
  end
  -- When command fails or no result, leave _sf_current_org_alias unchanged (e.g. from DeployFromPackage)
end

return {
  -- Lualine: show current Salesforce target org (cache only; refreshed on BufEnter or :SFRefreshOrg)
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function() _sf_refresh_statusline_org() end,
      })
      vim.defer_fn(function() _sf_refresh_statusline_org() end, 0)
      vim.api.nvim_create_user_command("SFRefreshOrg", function()
        _sf_refresh_statusline_org(true)
      end, { desc = "Refresh Salesforce org in statusline (run after changing target org)" })
      table.insert(opts.sections.lualine_x, {
        function()
          if type(_sf_current_org_alias) ~= "string" or _sf_current_org_alias == "" then return "" end
          return "SF: " .. _sf_current_org_alias
        end,
      })
    end,
  },
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

      -- Deploy from package: select manifest XML → select org → deploy in background, notify on completion
      local function get_manifest_dir()
        local cwd = vim.fn.getcwd()
        local dir = cwd
        for _ = 1, 20 do
          if vim.fn.filereadable(dir .. "/sfdx-project.json") == 1 or vim.fn.filereadable(dir .. "/sf-project.json") == 1 then
            local manifest = dir .. "/manifest"
            if vim.fn.isdirectory(manifest) == 1 then
              return manifest
            end
            return dir
          end
          local parent = vim.fn.fnamemodify(dir, ":h")
          if parent == dir then break end
          dir = parent
        end
        if vim.fn.isdirectory(cwd .. "/manifest") == 1 then
          return cwd .. "/manifest"
        end
        return cwd
      end

      local function get_manifest_xml_files()
        local manifest_dir = get_manifest_dir()
        local pattern = manifest_dir .. "/*.xml"
        local files = vim.fn.glob(pattern, true, true)
        return files or {}
      end

      -- Return the stored org alias (no CLI parsing); set via :SFRefreshOrg / BufEnter or when picking org in DeployFromPackage
      local function get_current_target_org()
        return (type(_sf_current_org_alias) == "string" and _sf_current_org_alias ~= "") and _sf_current_org_alias or nil
      end

      local function get_org_list()
        local use_sf = vim.fn.executable("sf") == 1
        local cmd = use_sf and "sf org list --json" or "sfdx force:org:list --json"
        local out = vim.fn.system(cmd)
        if out == nil or out == "" then return {} end
        local ok, data = pcall(vim.fn.json_decode, out)
        if not ok or not data or not data.result then return {} end
        local result = data.result
        local orgs = {}
        local function add(entry)
          if not entry then return end
          local alias = tostring(entry.alias or entry.username or "")
          local username = tostring(entry.username or "")
          local target = (entry.alias and entry.alias ~= "") and entry.alias or entry.username
          if target and target ~= "" then
            target = tostring(target)
            table.insert(orgs, { display = alias .. (username ~= "" and (" (" .. username .. ")") or ""), target_org = target })
          end
        end
        for _, e in ipairs(result.nonScratchOrgs or {}) do add(e) end
        for _, e in ipairs(result.scratchOrgs or {}) do add(e) end
        return orgs
      end

      -- Wrap org in double quotes if it contains spaces (escape any " inside)
      local function shellescape_org(org)
        if type(org) ~= "string" then return vim.fn.shellescape(tostring(org)) end
        if org:find("%s") then
          return '"' .. org:gsub('"', '\\"') .. '"'
        end
        return vim.fn.shellescape(org)
      end

      local function run_deploy_background(manifest_path, target_org, dry_run)
        local use_sf = vim.fn.executable("sf") == 1
        local dry_flag = (dry_run == true) and " --dry-run" or ""
        local org_arg = shellescape_org(target_org)
        local cmd = use_sf
          and ("sf project deploy start --manifest " .. vim.fn.shellescape(manifest_path) .. " --target-org " .. org_arg .. dry_flag)
          or ("sfdx force:source:deploy -x " .. vim.fn.shellescape(manifest_path) .. " -u " .. org_arg .. dry_flag)
        local verb = dry_run and "Validating" or "Deploying"
        local verb_past = dry_run and "Validation" or "Deployment"
        vim.notify(verb .. " to " .. target_org .. " ...", vim.log.levels.INFO, { title = "Salesforce" })
        local stdout, stderr = {}, {}
        local job_id = vim.fn.jobstart(cmd, {
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data) if data then for _, l in ipairs(data) do table.insert(stdout, l) end end end,
          on_stderr = function(_, data) if data then for _, l in ipairs(data) do table.insert(stderr, l) end end end,
          on_exit = function(_, code)
            vim.schedule(function()
              if code == 0 then
                vim.notify(verb_past .. " to " .. target_org .. " succeeded.", vim.log.levels.INFO, { title = "Salesforce" })
              else
                local msg = table.concat(stderr, " ")
                if msg == "" then msg = table.concat(stdout, " ") end
                vim.notify((verb_past .. " failed (exit %s). %s"):format(code, msg:sub(1, 200)), vim.log.levels.ERROR, { title = "Salesforce" })
              end
            end)
          end,
        })
        if job_id <= 0 then
          vim.notify("Failed to start " .. (dry_run and "validation" or "deploy") .. " job.", vim.log.levels.ERROR, { title = "Salesforce" })
        end
      end

      local function run_retrieve_background(manifest_path, target_org)
        local use_sf = vim.fn.executable("sf") == 1
        local org_arg = shellescape_org(target_org)
        local cmd = use_sf
          and ("sf project retrieve start --manifest " .. vim.fn.shellescape(manifest_path) .. " --target-org " .. org_arg)
          or ("sfdx force:source:retrieve -x " .. vim.fn.shellescape(manifest_path) .. " -u " .. org_arg)
        vim.notify("Retrieving from " .. target_org .. " ...", vim.log.levels.INFO, { title = "Salesforce" })
        local stdout, stderr = {}, {}
        local job_id = vim.fn.jobstart(cmd, {
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data) if data then for _, l in ipairs(data) do table.insert(stdout, l) end end end,
          on_stderr = function(_, data) if data then for _, l in ipairs(data) do table.insert(stderr, l) end end end,
          on_exit = function(_, code)
            vim.schedule(function()
              if code == 0 then
                vim.notify("Retrieve from " .. target_org .. " succeeded.", vim.log.levels.INFO, { title = "Salesforce" })
              else
                local msg = table.concat(stderr, " ")
                if msg == "" then msg = table.concat(stdout, " ") end
                vim.notify(("Retrieve failed (exit %s). %s"):format(code, msg:sub(1, 200)), vim.log.levels.ERROR, { title = "Salesforce" })
              end
            end)
          end,
        })
        if job_id <= 0 then
          vim.notify("Failed to start retrieve job.", vim.log.levels.ERROR, { title = "Salesforce" })
        end
      end

      local function start_package_flow(run_fn)
        local xml_files = get_manifest_xml_files()
        if #xml_files == 0 then
          vim.notify("No *.xml files found in manifest folder.", vim.log.levels.WARN, { title = "Salesforce" })
          return
        end
        vim.ui.select(xml_files, {
          prompt = "Select package XML",
          format_item = function(path)
            return vim.fn.fnamemodify(path, ":t")
          end,
        }, function(manifest_path)
          if not manifest_path then return end
          local orgs = get_org_list()
          if #orgs == 0 then
            vim.notify("No orgs found. Run org login first (e.g. <leader>sfa).", vim.log.levels.WARN, { title = "Salesforce" })
            return
          end
          vim.ui.select(orgs, {
            prompt = "Select target org",
            format_item = function(o)
              return o.display
            end,
          },           function(chosen)
            if chosen then
              _sf_current_org_alias = chosen.target_org
              run_fn(manifest_path, chosen.target_org)
            end
          end)
        end)
      end

      vim.api.nvim_create_user_command("DeployFromPackage", function()
        start_package_flow(function(manifest_path, target_org)
          run_deploy_background(manifest_path, target_org, false)
        end)
      end, { desc = "Deploy using a package XML from manifest folder" })

      vim.api.nvim_create_user_command("ValidateFromPackage", function()
        local xml_files = get_manifest_xml_files()
        if #xml_files == 0 then
          vim.notify("No *.xml files found in manifest folder.", vim.log.levels.WARN, { title = "Salesforce" })
          return
        end
        vim.ui.select(xml_files, {
          prompt = "Select package XML",
          format_item = function(path)
            return vim.fn.fnamemodify(path, ":t")
          end,
        }, function(manifest_path)
          if not manifest_path then return end
          local target_org = get_current_target_org()
          if not target_org then
            vim.notify("No target org set. Set one with <leader>sfs or sf config set target-org=...", vim.log.levels.WARN, { title = "Salesforce" })
            return
          end
          local pkg_name = vim.fn.fnamemodify(manifest_path, ":t")
          local choice = vim.fn.confirm(
            ("Are you sure you want to validate this %s with this Salesforce org [%s]?"):format(pkg_name, target_org),
            "&Yes\n&No",
            2
          )
          if choice == 1 then
            run_deploy_background(manifest_path, target_org, true)
          end
        end)
      end, { desc = "Validate (dry-run) using a package XML with default org" })

      vim.api.nvim_create_user_command("RetrieveFromPackage", function()
        local xml_files = get_manifest_xml_files()
        if #xml_files == 0 then
          vim.notify("No *.xml files found in manifest folder.", vim.log.levels.WARN, { title = "Salesforce" })
          return
        end
        vim.ui.select(xml_files, {
          prompt = "Select package XML",
          format_item = function(path)
            return vim.fn.fnamemodify(path, ":t")
          end,
        }, function(manifest_path)
          if not manifest_path then return end
          local target_org = get_current_target_org()
          if not target_org then
            vim.notify("No target org set. Set one with <leader>sfs or sf config set target-org=...", vim.log.levels.WARN, { title = "Salesforce" })
            return
          end
          local pkg_name = vim.fn.fnamemodify(manifest_path, ":t")
          local choice = vim.fn.confirm(
            ("Are you sure you want to retrieve %s from this Salesforce org [%s]?"):format(pkg_name, target_org),
            "&Yes\n&No",
            2
          )
          if choice == 1 then
            run_retrieve_background(manifest_path, target_org)
          end
        end)
      end, { desc = "Retrieve using a package XML with default org" })

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
