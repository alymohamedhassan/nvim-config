local options = {
  hijack_cursor = true,
  filters = {
    dotfiles = false,
    custom = { ".DS_Store", "__pycache__", ".git$" },
  },
  git = {
    enable = true,
    ignore = true,
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
  view = {
    -- side = "right",
    width = {
      min = 30,
      max = 50,
    },
  },
}

return options
