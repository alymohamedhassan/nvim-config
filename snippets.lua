local ls = require("luasnip")
-- for "all" filetypes create snippet for "func"
ls.add_snippets( "python", {
  ls.parser.parse_snippet(
    'def',
    'def ${1}(${2}):\n\t${3}\n'),
})
-- Map "Ctrl + p" (in insert mode)
-- to expand snippet and jump through fields.
vim.keymap.set(
  'i', '<C-p>',
  function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end
)
