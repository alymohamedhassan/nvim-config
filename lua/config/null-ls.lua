-- lua/config/null-ls.lua
local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")

-- Diagnostic source: checks each `SomeObject__c` reference via `sfdx force:schema:sobject:describe`
local sobject_exists = {
  name = "sobject_exists",
  method = methods.internal.DIAGNOSTICS,
  filetypes = { "apex" },
  generator = helpers.generator_factory({
    command = "bash",
    args = {
      "-c",
      [=[ 
awk '/\b([A-Z][A-Za-z0-9_]*)__c\b/ {
  obj = gensub(/.*\b([A-Z][A-Za-z0-9_]*)__c\b.*/, "\\1__c", "g");
  cmd = "sfdx force:schema:sobject:describe " obj " --json";
  cmd | getline out; close(cmd);
  if (out !~ ("\"name\"[[:space:]]*:[[:space:]]*\"" obj "\"")) {
    print FILENAME ":" FNR ":1: error: Custom object '" obj "' does not exist in org";
  }
}
]=] .. " " .. vim.api.nvim_buf_get_name(0),
    },
    to_stdin = false,
  }),
}

null_ls.setup({
  sources = {
    sobject_exists,
    -- you can add similar generators for ApexClass via `sfdx force:source:retrieve -m ApexClass:$class`
  },
})
