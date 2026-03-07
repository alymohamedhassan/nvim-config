return {
  {
    "mhartington/formatter.nvim",
    config = function()
      local formatter = require("formatter")
      formatter.setup({
        filetype = {
          apex = {
            -- Prettier Apex
            -- function()
            --   return {
            --     exe = "prettier",
            --     args = { "--plugin=prettier-plugin-apex", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
            --     stdin = true,
            --   }
            -- end,
            -- afmt (Rust-based Apex formatter)
            function()
              return {
                exe = "afmt",
                args = { vim.api.nvim_buf_get_name(0), "-c .afmt.toml" },
                stdin = true,
              }
            end,
          },
        },
      })
      -- Format on save for Apex files
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.cls", "*.trigger", "*.apex" },
        callback = function()
          vim.cmd("FormatWrite")
        end,
      })
    end,
  },
}
