-- Plugins are fetched/loaded via Neovim 0.12's native package manager.

vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/Saghen/blink.cmp',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/stevearc/conform.nvim',
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

-- blink.cmp
require('luasnip.loaders.from_vscode').lazy_load()
require('blink.cmp').setup({
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = "lua" },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  keymap = {
    preset="default",
  },
  cmdline = { enabled = false },
})

-- formatting (conform.nvim)
local function read_file(path)
  if not path or vim.fn.filereadable(path) == 0 then
    return ''
  end
  return table.concat(vim.fn.readfile(path), '\n')
end

local function find_upward(names, start)
  return vim.fs.find(names, { upward = true, path = start })[1]
end

local function package_json_content(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return ''
  end
  local pkg = find_upward({ 'package.json' }, vim.fs.dirname(filename))
  return read_file(pkg)
end

local function has_oxc_project(bufnr)
  local content = package_json_content(bufnr)
  if content == '' then
    return false
  end
  return content:match('"oxfmt"') ~= nil
    or content:match('"oxlint"') ~= nil
    or content:match('"oxc"') ~= nil
end

local function has_biome_project(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return false
  end
  local dir = vim.fs.dirname(filename)
  if find_upward({ 'biome.json', 'biome.jsonc' }, dir) then
    return true
  end
  local content = package_json_content(bufnr)
  return content:match('"@biomejs/biome"') ~= nil
    or content:match('"biome"') ~= nil
end

local function has_prettier_project(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return false
  end
  local dir = vim.fs.dirname(filename)
  if find_upward({
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.yml',
    '.prettierrc.yaml',
    '.prettierrc.json5',
    '.prettierrc.js',
    '.prettierrc.cjs',
    '.prettierrc.mjs',
    'prettier.config.js',
    'prettier.config.cjs',
    'prettier.config.mjs',
  }, dir) then
    return true
  end
  local content = package_json_content(bufnr)
  if content == '' then
    return false
  end
  return content:match('"prettier"%s*:') ~= nil
    or content:match('"prettier"') ~= nil
    or content:match('"prettierd"') ~= nil
end

local function should_skip_format(bufnr)
  if vim.bo[bufnr].buftype ~= '' then
    return true
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return false
  end

  local normalized = filename:gsub('\\', '/'):lower()
  for _, needle in ipairs({
    '/node_modules/',
    '/.git/',
    '/dist/',
    '/build/',
    '/out/',
    '/coverage/',
    '/vendor/',
    '/.next/',
    '/.nuxt/',
    '/.svelte-kit/',
    '/storybook-static/',
  }) do
    if normalized:find(needle, 1, true) then
      return true
    end
  end

  local base = vim.fs.basename(normalized)
  if base:match('%.min%.js$')
    or base:match('%.min%.css$')
    or base:match('%.generated%.')
    or base:match('%.gen%.')
    or base == 'package-lock.json'
    or base == 'pnpm-lock.yaml'
    or base == 'yarn.lock'
  then
    return true
  end

  local head = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
  for _, line in ipairs(head) do
    local lower = line:lower()
    if lower:find('@generated', 1, true)
      or lower:find('code generated', 1, true)
      or lower:find('do not edit', 1, true)
    then
      return true
    end
  end

  return false
end

local function web_formatters(bufnr)
  if has_oxc_project(bufnr) then
    return { 'oxfmt' }
  end
  if has_biome_project(bufnr) then
    return { 'biome' }
  end
  if has_prettier_project(bufnr) then
    return { 'prettierd', 'prettier', stop_after_first = true }
  end
  return {}
end

local formatters_by_ft = {
  lua = { 'stylua' },
  python = { 'ruff_format', 'black', stop_after_first = true },
  go = { 'goimports', 'gofmt', stop_after_first = true },
}

for _, ft in ipairs({
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'json',
  'jsonc',
  'css',
  'scss',
  'less',
  'html',
  'yaml',
  'markdown',
  'markdown.mdx',
  'graphql',
  'vue',
  'svelte',
  'astro',
}) do
  formatters_by_ft[ft] = web_formatters
end

local conform_util = require('conform.util')
require('conform').setup({
  formatters_by_ft = formatters_by_ft,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  format_on_save = function(bufnr)
    if should_skip_format(bufnr) then
      return nil
    end
    return {
      timeout_ms = 800,
      lsp_format = 'fallback',
      quiet = true,
    }
  end,
  formatters = {
    oxfmt = {
      command = 'oxfmt',
      args = { '--stdin-filepath', '$FILENAME' },
      cwd = conform_util.root_file({ 'package.json', '.git' }),
      require_cwd = true,
      stdin = true,
    },
  },
})
map('n', '<leader>cf', function()
  require('conform').format({ lsp_format = 'fallback', timeout_ms = 1200 })
end, 'Format buffer')

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
