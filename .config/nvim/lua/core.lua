vim.o.number = true
vim.o.relativenumber = true

vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

vim.o.signcolumn = 'yes'
-- vim.o.cursorline = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.undofile = true
vim.o.swapfile = false

vim.o.clipboard = 'unnamedplus'

vim.g.loaded_netrw = 1 -- disable netrw to avoid conflict with Oil
vim.g.loaded_netrwPlugin = 1 -- disable netrw to avoid conflict with Oil

vim.o.termguicolors=true

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})
