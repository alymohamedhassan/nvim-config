return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  build = "make BUILD_FROM_SOURCE=true",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "echasnovski/mini.icons",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
  },
  config = function(_, opts)
    -- 1. Load native libraries
    require("avante_lib").load()
    -- 2. Setup Avante with your options
    require("avante").setup(vim.tbl_deep_extend("force", {
      provider = "gemini",
      gemini = {
        model = "gemini-1.5-pro-exp-0827",
        temperature = 0,
        max_tokens = 4096,
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_apply_diff_after_generation = false,
      },
    }, opts))
  end,
}
