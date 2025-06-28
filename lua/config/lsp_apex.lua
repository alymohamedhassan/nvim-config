local lspconfig = require("lspconfig")

-- Register the apex_ls server if not already registered
-- if not lspconfig.configs.apex_ls then
--   lspconfig.configs.apex_ls = {
--     default_config = {
--       cmd = { "/Users/aly/.local/share/apex/apex-jorje-lsp.jar" }, -- update this path
--       filetypes = { "apexcode", "cls", "trigger", "apex" },
--       root_dir = lspconfig.util.root_pattern("sfdx-project.json"),
--       settings = {},
--     },
--   }
-- end
--
-- -- Now setup the server
-- lspconfig.apex_ls.setup({
--   on_attach = function(client, bufnr)
--     -- Optional: your on_attach logic here
--   end,
-- })
