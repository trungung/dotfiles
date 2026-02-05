-- Plugins are fetched/loaded via Neovim 0.12's native package manager.

vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/catppuccin/nvim',
}, { load = true })

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Theme
require('catppuccin').setup({
  transparent_background = true,
  auto_integrations = true,
})
vim.cmd.colorscheme('catppuccin')

-- mini.pick uses its own highlight groups; make its floats respect transparency.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('user.mini_pick_hl', { clear = true }),
  callback = function()
    local set = vim.api.nvim_set_hl
    for _, group in ipairs({
      'MiniPickNormal',
      'MiniPickBorder',
      'MiniPickPrompt',
    }) do
      set(0, group, { bg = 'NONE' })
    end
  end,
})
vim.cmd('doautocmd ColorScheme')

-- which-key
require('which-key').setup({})

-- Oil
require('oil').setup({})
map('n', '<leader>e', '<Cmd>Oil<CR>', 'Explorer (Oil)')

-- mini.pick
local pick = require('mini.pick')
pick.setup({})
map('n', '<leader>ff', function() pick.builtin.files() end, 'Find files')
map('n', '<leader>fg', function() pick.builtin.grep_live() end, 'Live grep')

-- mini.move
require('mini.move').setup({})
