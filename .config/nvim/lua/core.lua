vim.o.number = true         -- show absolute line number on current line
vim.o.relativenumber = true -- show relative numbers for fast motions

vim.o.scrolloff = 8         -- keep context lines above/below cursor
vim.o.sidescrolloff = 8     -- keep horizontal context near cursor

vim.o.signcolumn = 'yes'
-- vim.o.cursorline = true  -- highline the current line

vim.o.ignorecase = true         -- case-insensitive search by default
vim.o.smartcase = true          -- make search case-sensitive if uppercase used

vim.o.undofile = true           -- persist undo history across sessions
vim.o.swapfile = false          -- disable swap files

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

vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>', { silent = true, desc = 'Clear search highlight' })

vim.g.loaded_netrw = 1          -- disable netrw to avoid conflict with Oil
vim.g.loaded_netrwPlugin = 1    -- disable netrw plugin to avoid conflict

vim.o.termguicolors = true      -- enable true-color support

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
