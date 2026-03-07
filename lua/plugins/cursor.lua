return {
  {
    "bka9/cursor.nvim",
    event = "VeryLazy",
    opts = {
      cmd = "cursor-agent",
      parameters = {},
      extra_args = {},
      window = {
        type = "float",
        width = 0.6,
        height = 0.6,
        border = "rounded",
        position = "bottom",
        focus = true,
      },
      start_in_insert = true,
      auto_close_on_exit = false,
      disable_default_keymaps = false,
    },
    config = function(_, opts)
      require("cursor_agent").setup(opts)
    end,
  },
}
