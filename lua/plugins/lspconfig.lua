return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        apex_ls = function(_, opts)
          -- Absolute path to your Java 11+ executable:
          opts.cmd = {
            "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/bin/java",
            "-jar",
            "/Users/aly/.local/share/apex/apex-jorje-lsp.jar",
          }
          opts.filetypes = { "apex", "cls", "trigger" }
          opts.apex_enable_semantic_errors = true
          require("lspconfig").apex_ls.setup(opts)
        end,
      },
    },
  },
}
