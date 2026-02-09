-- Plugins are fetched/loaded via Neovim 0.12's native package manager.

-- Copilot: keep default <Tab> mapping so ghost text is easy to accept.
vim.g.copilot_no_tab_map = false

vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/Saghen/blink.cmp',
  'https://github.com/github/copilot.vim',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
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

-- which-key: discover leader groups while you are still learning keymaps.
local wk = require('which-key')
wk.setup({})
if wk.add then
  wk.add({
    { '<leader>c', group = 'Code' },
    { '<leader>f', group = 'Find' },
    { '<leader>h', group = 'Git Hunks' },
  })
else
  wk.register({
    c = { name = 'Code' },
    f = { name = 'Find' },
    h = { name = 'Git Hunks' },
  }, { prefix = '<leader>' })
end

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
map('n', '<leader>fb', function() require('fzf-lua').buffers() end, 'Find buffers')
map('n', '<leader>fo', function() require('fzf-lua').oldfiles() end, 'Recent files')

-- blink.cmp: use default completion keys and leave Tab to Copilot.
require('luasnip.loaders.from_vscode').lazy_load()
require('blink.cmp').setup({
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = "lua" },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  keymap = {
    preset = "default",
    ['<Tab>'] = false,
    ['<S-Tab>'] = false,
  },
  cmdline = { enabled = false },
})

-- Formatting policy lives in plugins/format.lua:
-- prefer project/system formatters via Conform, then fall back to LSP formatting.
require('plugins.format').setup(map)

-- LSP (Neovim 0.11+)
-- Mason installs and updates the default server set below.
local lsp_servers = {
  'lua_ls',
  'ts_ls',
  'html',
  'cssls',
  'tailwindcss',
  'angularls',
  'jsonls',
  'yamlls',
  'bashls',
  'pyright',
  'gopls',
  'csharp_ls',
  'eslint',
  'biome',
}

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = lsp_servers,
  automatic_enable = false,
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})

vim.lsp.config('eslint', {
  -- Attach ESLint only when project config files are present.
  root_markers = {
    'eslint.config.js',
    'eslint.config.cjs',
    'eslint.config.mjs',
    'eslint.config.ts',
    'eslint.config.cts',
    'eslint.config.mts',
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.yml',
    '.eslintrc.yaml',
    '.eslintrc.json',
  },
})

vim.lsp.config('biome', {
  -- Attach Biome only when a Biome config is present.
  root_markers = {
    'biome.json',
    'biome.jsonc',
  },
})

vim.lsp.enable(lsp_servers)

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
