vim.g.mapleader = ' '

vim.o.number = true
vim.o.relativenumber = true

vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

vim.o.signcolumn = 'yes'
-- vim.o.cursorline=true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.undofile = true
vim.o.swapfile = false

vim.o.clipboard = 'unnamedplus'

vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/catppuccin/nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
}, { load = true })

require('catppuccin').setup({
  transparent_background = true,
  auto_integrations = true,
})

vim.cmd.colorscheme('catppuccin')

-- Oil (file explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require('oil').setup({})
vim.keymap.set('n', '<leader>e', '<Cmd>Oil<CR>', { desc = 'Explorer (Oil)', silent = true })

-- mini.pick (files + grep)
local pick = require('mini.pick')
pick.setup({})
vim.keymap.set('n', '<leader>ff', function()
  pick.builtin.files()
end, { desc = 'Find files', silent = true })
vim.keymap.set('n', '<leader>fg', function()
  pick.builtin.grep_live()
end, { desc = 'Live grep', silent = true })

require('mini.move').setup({})
require('mini.pairs').setup({})
require('gitsigns').setup({})
