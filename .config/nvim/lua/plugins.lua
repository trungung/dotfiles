-- Plugins are fetched/loaded via Neovim 0.12's native package manager.

vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/ibhagwan/fzf-lua',
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

-- Make common floating UIs respect terminal background ("transparent" look).
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('user.transparent_floats', { clear = true }),
  callback = function()
    local set = vim.api.nvim_set_hl
    for _, group in ipairs({
      'NormalFloat',
      'FloatBorder',
      'FzfLuaNormal',
      'FzfLuaBorder',
      'FzfLuaTitle',
      'FzfLuaPreviewNormal',
      'FzfLuaPreviewBorder',
    }) do
      set(0, group, { bg = 'NONE' })
    end
  end,
})
vim.api.nvim_exec_autocmds('ColorScheme', {})

-- which-key
require('which-key').setup({})

-- Oil
require('oil').setup({})
map('n', '<leader>e', '<Cmd>Oil<CR>', 'Explorer (Oil)')

-- fzf-lua (files + live grep)
require('fzf-lua').setup({})
map('n', '<leader>ff', function() require('fzf-lua').files() end, 'Find files')
map('n', '<leader>fg', function() require('fzf-lua').live_grep() end, 'Live grep')

-- mini.move
require('mini.move').setup({})
