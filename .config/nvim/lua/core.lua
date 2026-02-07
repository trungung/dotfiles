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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user.lsp_attach', { clear = true }),
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
