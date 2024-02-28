local configs = require "plugins.configs.lspconfig"
local on_attach = configs.on_attach
local capabilities = configs.capabilities

local lspconfig = require "lspconfig"

local servers = {
  "terraformls",
  "tflint",
  "dockerls",
  "docker_compose_language_service",
  "html",
  "cssls",
  "jsonls",
  "gopls",
  "prismals",
  "emmet_language_server",
  "tsserver",
  "pyright",
  "prismals",
  "bashls",
  "eslint-lsp",
}

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

Commands = {}
for _, lsp in ipairs(servers) do
  if lsp == "tsserver" then
    Commands = {
      OrganizeImports = {
        organize_imports,
        description = "Organize Imports",
      },
    }
  end

  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    commands = Commands,
  }
end
