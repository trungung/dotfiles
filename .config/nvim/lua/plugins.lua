-- Plugins are fetched/loaded via Neovim 0.12's native package manager.

vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/lewis6991/gitsigns.nvim',
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

-- gitsigns
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local bmap = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    bmap(']h', gs.next_hunk, 'Next hunk')
    bmap('[h', gs.prev_hunk, 'Prev hunk')
    bmap('<leader>hs', gs.stage_hunk, 'Stage hunk')
    bmap('<leader>hr', gs.reset_hunk, 'Reset hunk')
    bmap('<leader>hp', gs.preview_hunk, 'Preview hunk')
    bmap('<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
  end,
})

-- fzf-lua (files + live grep)
require('fzf-lua').setup({
  keymap = {
    fzf = {
      ['alt-j'] = 'down',
      ['alt-k'] = 'up',
    },
  },
})
map('n', '<leader>ff', function() require('fzf-lua').files() end, 'Find files')
map('n', '<leader>fg', function() require('fzf-lua').live_grep() end, 'Live grep')

-- LSP (Neovim 0.11+)
-- Install language servers via :Mason, then enable them here.
require('mason').setup({})
vim.lsp.enable({
  'lua_ls',
  'ts_ls',
  'html',
  'cssls',
  'jsonls',
  'tailwindcss',
  'yamlls',
  'bashls',
  'angularls',
  'pyright',
  'gopls',
  'csharp_ls',
})

-- treesitter
-- No need to call setup for nvim-treesitter to work using default values.
require('nvim-treesitter').install({
  -- web
  'javascript',
  'typescript',
  'tsx',
  'json',
  'html',
  'css',
  -- backend
  'python',
  'go',
  'gomod',
  'gowork',
  'gosum',
  'c_sharp',
  -- nvim/config niceties
  'lua',
  'vim',
  'vimdoc',
  'bash',
  'yaml',
  'toml',
  'markdown',
  'markdown_inline',
  'query',
})
-- enable treesitter highlighting for any buffer with a parser
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user.treesitter', { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- mini
require('mini.move').setup({})
require('mini.pairs').setup({})
