-- Neovim 0.12 built-in package manager
vim.g.copilot_no_tab_map = false  -- keep <Tab> for Copilot ghost text accept

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
  'https://github.com/rebelot/kanagawa.nvim',
}, { load = true })

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- ── theme ──────────────────────────────────────────────────────────────────

require('kanagawa').setup({
  colors = {
    theme = {
      all = { ui = { bg_gutter = 'none' } },
    },
  },
})
vim.cmd('colorscheme kanagawa-dragon')

-- keep floating UIs aligned with transparent terminal background
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('user.transparent_floats', { clear = true }),
  callback = function()
    local set = vim.api.nvim_set_hl
    for _, group in ipairs({
      'NormalFloat', 'FloatBorder',
      'FzfLuaNormal', 'FzfLuaBorder', 'FzfLuaTitle',
      'FzfLuaPreviewNormal', 'FzfLuaPreviewBorder',
    }) do
      set(0, group, { bg = 'NONE' })
    end
  end,
})
vim.api.nvim_exec_autocmds('ColorScheme', {})

-- ── ui ─────────────────────────────────────────────────────────────────────

local wk = require('which-key')
wk.setup({})
wk.add({
  { '<leader>c', group = 'Code' },
  { '<leader>f', group = 'Find' },
  { '<leader>h', group = 'Git Hunks' },
})

require('mini.move').setup({})
require('mini.pairs').setup({})
require('mini.statusline').setup({})
require('mini.indentscope').setup({
  draw = { animation = require('mini.indentscope').gen_animation.none() },
  options = { indent_at_cursor = false },
})

-- ── explorer ───────────────────────────────────────────────────────────────

require('oil').setup({
  view_options = {
    show_hidden = true,
  },
})
map('n', '<leader>e', '<Cmd>Oil<CR>', 'Explorer (Oil)')

-- ── git ────────────────────────────────────────────────────────────────────

require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local bmap = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    bmap(']h', gs.next_hunk,                              'Next hunk')
    bmap('[h', gs.prev_hunk,                              'Prev hunk')
    bmap('<leader>hs', gs.stage_hunk,                     'Stage hunk')
    bmap('<leader>hr', gs.reset_hunk,                     'Reset hunk')
    bmap('<leader>hp', gs.preview_hunk,                   'Preview hunk')
    bmap('<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
  end,
})

-- ── fuzzy finder ───────────────────────────────────────────────────────────

local fzf_ignore_patterns = {
  "node_modules/",
  "dist/",
  "%.next/",
  "%.git/",
  "%.gitlab/",
  "build/",
  "target/",
  "package%-lock%.json",
  "pnpm%-lock%.yaml",
  "yarn%.lock",
}

require('fzf-lua').setup({
  file_ignore_patterns = fzf_ignore_patterns,
  files = {
    fd_opts = table.concat({
      "--color=never",
      "--type f",
      "--hidden",
      "--follow",
      "--exclude .git",
      "--exclude node_modules",
      "--exclude dist",
      "--exclude .next",
      "--exclude .gitlab",
      "--exclude build",
      "--exclude target",
      "--exclude package-lock.json",
      "--exclude pnpm-lock.yaml",
      "--exclude yarn.lock",
    }, " "),
  },
  grep = {
    rg_opts = table.concat({
      "--column",
      "--line-number",
      "--no-heading",
      "--color=always",
      "--smart-case",
      "--max-columns=4096",
      "--hidden",
      "--glob '!.git/*'",
      "--glob '!node_modules/*'",
      "--glob '!dist/*'",
      "--glob '!.next/*'",
      "--glob '!.gitlab/*'",
      "--glob '!build/*'",
      "--glob '!target/*'",
      "--glob '!package-lock.json'",
      "--glob '!pnpm-lock.yaml'",
      "--glob '!yarn.lock'",
      "-e",
    }, " "),
  },
  keymap = {
    fzf = {
      ['alt-j'] = 'down',
      ['alt-k'] = 'up',
    },
  },
})
map('n', '<leader>ff', function()
  require('fzf-lua').files({
    hidden = true,
    no_ignore = true,
  })
end, 'Find files')
map('n', '<leader>fg', function() require('fzf-lua').live_grep() end, 'Live grep')
map('n', '<leader>fb', function() require('fzf-lua').buffers() end,   'Find buffers')
map('n', '<leader>fo', function() require('fzf-lua').oldfiles() end,  'Recent files')

-- ── completion ─────────────────────────────────────────────────────────────

require('luasnip.loaders.from_vscode').lazy_load()
require('blink.cmp').setup({
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },  -- native binary unavailable; lua is fine
  completion = {
    menu = { auto_show = false },       -- open manually with <C-space>
    ghost_text = { enabled = false },   -- Copilot handles inline ghost text
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  keymap = {
    preset = 'default',
    ['<Tab>']   = false,  -- reserved for Copilot
    ['<S-Tab>'] = false,
  },
  cmdline = { enabled = false },
})

-- ── formatting ─────────────────────────────────────────────────────────────

-- rules live in plugins/format.lua; falls back to LSP when no formatter found
require('plugins.format').setup(map)

-- ── lsp ────────────────────────────────────────────────────────────────────

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
      diagnostics = { globals = { 'vim' } },
    },
  },
})

vim.lsp.config('angularls', {
  -- attach only when an Angular workspace is present
  workspace_required = true,
})

vim.lsp.config('eslint', {
  -- attach only when a project config file is present
  root_markers = {
    'eslint.config.js', 'eslint.config.cjs', 'eslint.config.mjs',
    'eslint.config.ts', 'eslint.config.cts', 'eslint.config.mts',
    '.eslintrc', '.eslintrc.js', '.eslintrc.cjs',
    '.eslintrc.yml', '.eslintrc.yaml', '.eslintrc.json',
  },
})

vim.lsp.config('biome', {
  -- attach only when a biome config is present
  root_markers = { 'biome.json', 'biome.jsonc' },
  -- match UTF-16 used by ts_ls/tailwindcss to avoid position offset bugs
  capabilities = {
    general = { positionEncodings = { 'utf-16' } },
  },
})

vim.lsp.enable(lsp_servers)

-- ── treesitter ─────────────────────────────────────────────────────────────

require('nvim-treesitter').install({
  -- web
  'javascript', 'typescript', 'tsx', 'json', 'html', 'css',
  -- backend
  'python', 'go', 'gomod', 'gowork', 'gosum', 'c_sharp',
  -- nvim / config
  'lua', 'vim', 'vimdoc', 'bash', 'yaml', 'toml',
  'markdown', 'markdown_inline', 'query',
})

-- enable treesitter highlighting for any buffer with a parser
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user.treesitter', { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- ── quick help ─────────────────────────────────────────────────────────────

local function open_tutor_keys()
  local lines = {
    'Neovim Quick Keys (VS Code-friendly)',
    '',
    'Find',
    '  <leader>ff  Find files',
    '  <leader>fg  Live grep',
    '  <leader>fb  Buffers',
    '  <leader>fo  Recent files',
    '',
    'Code',
    '  gd          Go to definition',
    '  gr          Find references',
    '  K           Hover docs',
    '  <leader>ca  Code action',
    '  <leader>rn  Rename symbol',
    '  <leader>cd  Line diagnostics',
    '  <leader>cf  Format buffer',
    '',
    'Git / Explorer',
    '  ]h / [h     Next/prev git hunk',
    '  <leader>hs  Stage hunk',
    '  <leader>hr  Reset hunk',
    '  <leader>e   Explorer (Oil)',
    '',
    'Completion',
    '  <Tab>       Accept Copilot ghost text',
    '  <C-space>   Open Blink completion menu',
    '  <C-n>/<C-p> Select next/previous Blink item',
    '  <C-y>       Confirm Blink completion item',
    '',
    'Close this help with q or <Esc>.',
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'markdown'

  local max_line = 0
  for _, line in ipairs(lines) do
    max_line = math.max(max_line, vim.fn.strdisplaywidth(line))
  end

  local width  = math.max(52, math.min(max_line + 4, vim.o.columns - 4))
  local height = math.max(12, math.min(#lines + 2,   vim.o.lines - 4))
  local row    = math.max(0,  math.floor((vim.o.lines   - height) / 2 - 1))
  local col    = math.max(0,  math.floor((vim.o.columns - width)  / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    style    = 'minimal',
    border   = 'rounded',
    width    = width,
    height   = height,
    row      = row,
    col      = col,
    title     = ' NvimTutorKeys ',
    title_pos = 'center',
  })
  vim.wo[win].wrap = false

  vim.keymap.set('n', 'q',   '<Cmd>close<CR>', { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', '<Esc>', '<Cmd>close<CR>', { buffer = buf, silent = true, nowait = true })
end

vim.api.nvim_create_user_command('NvimTutorKeys', open_tutor_keys, {
  desc = 'Show quick keymap help for daily editing flow',
})
map('n', '<leader>?', '<Cmd>NvimTutorKeys<CR>', 'Keymap quick help')
