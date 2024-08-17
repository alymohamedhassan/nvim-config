local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local sources = {
  formatting.prettierd,
  formatting.black,
  -- formatting.eslint_d.with {
  --   filetypes = { "typescript", "javascript" },
  -- },
  formatting.stylua,
  formatting.reorder_python_imports,
  formatting.stylua,
  formatting.gofumpt,
  formatting.terraform_fmt.with {
    filetypes = { "terraform", "tf", "terraform-vars", "hcl" },
  },
  formatting.sqlfmt,

  lint.shellcheck,
  -- lint.ruff,
  -- lint.eslint_d,
}

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { async = false }
        end,
      })
    end
  end,
}
