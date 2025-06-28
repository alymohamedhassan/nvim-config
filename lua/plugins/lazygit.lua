return {
  {
    "kdheepak/lazygit.nvim",
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>lg",
        ":LazyGit<CR>",
        desc = "LazyGit window",
        mode = { "n", "v" },
      },
    },
  },
}
