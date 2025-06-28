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
    end,
  },
}
