vim.o.number = true         -- show absolute line number on current line
vim.o.relativenumber = true -- show relative numbers for fast motions

vim.o.scrolloff = 8         -- keep context lines above/below cursor
vim.o.sidescrolloff = 8     -- keep horizontal context near cursor

vim.o.signcolumn = 'yes'
-- vim.o.cursorline = true  -- highline the current line

vim.o.ignorecase = true         -- case-insensitive search by default
vim.o.smartcase = true          -- make search case-sensitive if uppercase used
vim.o.hlsearch = true           -- highlight all matches after / or ? search

vim.o.undofile = true           -- persist undo history across sessions
vim.o.swapfile = false          -- disable swap files
vim.o.autoread = true           -- auto-reload files changed outside Neovim

vim.o.clipboard = 'unnamedplus' -- share clipboard with system

vim.o.wrap = true               -- soft-wrap long lines on screen
vim.o.linebreak = true          -- wrap at word boundaries
vim.o.breakindent = true        -- preserve indentation on wrapped lines

vim.o.expandtab = true          -- insert spaces when pressing Tab
vim.o.tabstop = 2               -- visual width of hard tab characters
vim.o.shiftwidth = 2            -- indent width for >>, <<, and auto-indent
vim.o.softtabstop = 2           -- Tab/Backspace behave like 2 spaces
vim.o.smartindent = true        -- enable simple language-aware indentation
vim.o.shiftround = true         -- round indent shifts to shiftwidth multiples

vim.o.mouse = 'a'               -- enable mouse support in all modes
vim.o.updatetime = 250          -- faster updates for diagnostics/signs
vim.o.timeoutlen = 400          -- shorter wait for mapped key sequences

vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Down (wrapped)' })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Up (wrapped)' })
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>', { silent = true, desc = 'Clear search highlight' })
vim.keymap.set('n', '<leader>?', '<Cmd>NvimTutorKeys<CR>', { silent = true, desc = 'Keymap quick help' })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('user.yank_highlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('user.autoread_checktime', { clear = true }),
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.bo.buftype == '' then
      vim.cmd('checktime')
    end
  end,
})

vim.g.loaded_netrw = 1       -- disable netrw to avoid conflict with Oil
vim.g.loaded_netrwPlugin = 1 -- disable netrw plugin to avoid conflict

vim.o.termguicolors = true   -- enable true-color support

vim.diagnostic.config({
  virtual_text = true,   -- show diagnostics inline
  virtual_lines = false, -- do not render diagnostics as extra lines
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  float = {
    border = "rounded",
    souce = "if_many",
  }
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user.lsp_attach', { clear = true }), -- buffer-local LSP maps
  callback = function(args)
    local bmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
    end

    bmap('n', 'K', vim.lsp.buf.hover, 'LSP Hover')
    bmap('n', 'gd', vim.lsp.buf.definition, 'LSP Definition')
    bmap('n', 'gr', vim.lsp.buf.references, 'LSP References')
    bmap('n', 'gi', vim.lsp.buf.implementation, 'LSP Implementation')
    bmap('n', '<leader>rn', vim.lsp.buf.rename, 'LSP Rename')
    bmap({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'LSP Code action')
    bmap('n', '<leader>cd', vim.diagnostic.open_float, 'Line diagnostics')
  end,
})

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
    'Git/Explorer',
    '  ]h / [h     Next/prev git hunk',
    '  <leader>hs  Stage hunk',
    '  <leader>hr  Reset hunk',
    '  <leader>e   Explorer (Oil)',
    '',
    'Completion',
    '  <Tab>       Accept suggestion / next snippet slot',
    '  <S-Tab>     Previous snippet slot',
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

  local width = math.max(52, math.min(max_line + 4, vim.o.columns - 4))
  local height = math.max(12, math.min(#lines + 2, vim.o.lines - 4))
  local row = math.max(0, math.floor((vim.o.lines - height) / 2 - 1))
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    width = width,
    height = height,
    row = row,
    col = col,
    title = ' NvimTutorKeys ',
    title_pos = 'center',
  })
  vim.wo[win].wrap = false

  vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', '<Esc>', '<Cmd>close<CR>', { buffer = buf, silent = true, nowait = true })
end

vim.api.nvim_create_user_command('NvimTutorKeys', open_tutor_keys, {
  desc = 'Show quick keymap help for daily editing flow',
})
