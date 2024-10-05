local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = require "custom.configs.nvim-treesitter",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
    build = ":TSUpdate",
    opts = function()
      local conf = require "plugins.configs.telescope"
      conf.defaults.mappings.i = {
        ["C-j>"] = require("telescope.actions").move_selection_next,
        ["<Esc>"] = require("telescope.actions").close,
      }
      return conf
    end,
  },
  {
    "folke/which-key.nvim",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
  },
  -- In order to modify the `lspconfig` configuration:
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "nvimtools/none-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
      {
        "windwp/nvim-ts-autotag",
        config = function()
          require("nvim-ts-autotag").setup()
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = require "custom.configs.nvim_tree",
  },
  {
    "williamboman/mason.nvim",
    opts = require "custom.configs.mason",
  },
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIToggle" },
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
  },
  {
    "nomnivore/ollama.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    -- All the user commands added by the plugin
    cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

    keys = {
      {
        "<leader>oo",
        ":<c-u>lua require('ollama').prompt()<cr>",
        desc = "ollama prompt",
        mode = { "n", "v" },
      },
      {
        "<leader>oG",
        ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
        desc = "ollama Generate Code",
        mode = { "n", "v" },
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  }, -- lua with packer.nvim
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    config = require "custom.snippets",
  },
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
  {
    "max397574/better-escape.nvim",
    lazy = false,
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "preservim/vimux",
    lazy = false,
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup {
        -- config
        -- theme = "doom",
        theme = "hyper",
        config = {
          center = {
            {
              icon = " ",
              icon_hl = "Title",
              desc = "Find File",
              desc_hl = "String",
              key = "ff",
              keymap = "SPC f f",
              key_hl = "Number",
              key_format = " %s", -- remove default surrounding `[]`
              action = "Telescope find_files",
            },
            {
              icon = " ",
              desc = "Live Grep",
              key = "fw",
              keymap = "SPC f w",
              key_format = " %s", -- remove default surrounding `[]`
              action = "Telescope live_grep",
            },
            {
              icon = " ",
              desc = "Create a python project",
              key = "py",
              action = 'call VimuxRunCommand("aicoder")',
            },
          },
        },
      }
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*]],
      },
      search = {
        pattern = [[\b(KEYWORDS)\b]],
      },
    },
  },
  {
    "prisma/vim-prisma",
    lazy = false,
  },
  { "folke/neodev.nvim", opts = {} },
  { "averms/black-nvim" },
  {
    "jonathanmorris180/salesforce.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "andrewferrier/wrapping.nvim",
    lazy = false,
    config = function()
      require("wrapping").setup()
    end,
  },
  {
    "xixiaofinland/sf.nvim",
    branch = "dev",
    lazy = false,
    -- dir = "~/projects/sf.nvim",

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },

    config = function()
      require("sf").setup() -- important to call setup() to init the plugin!
    end,
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    lazy = false,
    config = true,
  },
}
return plugins
