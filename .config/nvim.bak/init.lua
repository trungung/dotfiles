-- =========================
-- Minimal Neovim 0.12 Setup
-- =========================
-- Uses native vim.lsp.config (no lspconfig framework)

-- =========================
-- 1. LEADER (set before everything)
-- =========================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =========================
-- 2. BASIC OPTIONS
-- =========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.clipboard = "unnamedplus"
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.smoothscroll = true
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.breakindent = true
vim.o.grepprg = "rg --vimgrep --no-messages --smart-case"

-- Better completion experience
vim.o.completeopt = "menu,menuone,noinsert,popup"
vim.o.pumheight = 10

-- =========================
-- 3. PLUGINS (vim.pack.add - 0.12 only)
-- =========================
vim.pack.add({
  "https://github.com/catppuccin/nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/brenoprata10/nvim-highlight-colors",
})
-- NOTE: Removed mason-lspconfig and nvim-lspconfig - using native vim.lsp.config instead

-- =========================
-- 4. THEME
-- =========================
require("catppuccin").setup({
  transparent_background = true,
  integrations = {
    gitsigns = true,
    treesitter = true,
    mason = true,
    which_key = true,
  },
})
vim.cmd.colorscheme("catppuccin")

-- =========================
-- 5. PLUGIN CONFIGS
-- =========================

-- Gitsigns
require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local opts = { buffer = bufnr }

    vim.keymap.set("n", "]h", gs.next_hunk, vim.tbl_extend("force", opts, { desc = "Next hunk" }))
    vim.keymap.set("n", "[h", gs.prev_hunk, vim.tbl_extend("force", opts, { desc = "Previous hunk" }))
    vim.keymap.set("n", "<leader>hs", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
    vim.keymap.set("n", "<leader>hr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
    vim.keymap.set("n", "<leader>hp", gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))
    vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, vim.tbl_extend("force", opts, { desc = "Blame line" }))
  end,
})

-- Highlight colors (hex colors in code)
require("nvim-highlight-colors").setup({
  render = "virtual",
  virtual_symbol = "●",
  virtual_symbol_suffix = "",
})

-- Oil (file explorer)
require("oil").setup({
  keymaps = {
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["q"] = "actions.close",
  },
  columns = { "icon", "size", "mtime" },
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
})

-- Treesitter
require("nvim-treesitter").setup({
  ensure_installed = {
    "lua", "javascript", "typescript", "tsx",
    "python", "json", "html", "css", "markdown",
    "bash", "vim", "vimdoc", "yaml", "toml",
  },
  auto_install = true,
})

-- Enable treesitter highlighting per filetype
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local ok = pcall(vim.treesitter.start)
    if ok then
      vim.bo.syntax = "off"
    end
  end,
})

-- FZF-Lua (fuzzy finder)
require("fzf-lua").setup({
  winopts = {
    preview = { layout = "vertical" },
  },
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
    },
  },
})

-- Which-key
require("which-key").setup({
  delay = 200,
})

-- Mason (for installing LSP servers)
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

-- =========================
-- 6. LSP SETUP (Native vim.lsp.config for 0.11+)
-- =========================
-- See :help lspconfig-nvim-0.11

-- Define LSP server configurations
-- These names must match the server command names
vim.lsp.config["ts_ls"] = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}

vim.lsp.config["lua_ls"] = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}

vim.lsp.config["pyright"] = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
}

vim.lsp.config["html"] = {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { ".git" },
}

vim.lsp.config["cssls"] = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { ".git" },
}

vim.lsp.config["jsonls"] = {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
}

vim.lsp.config["eslint"] = {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", ".git" },
  settings = {
    workingDirectory = { mode = "auto" },
    format = true,
    quiet = false,
  },
}

-- Enable the servers (this tells Neovim to actually start them)
vim.lsp.enable({
  "ts_ls",
  "lua_ls",
  "pyright",
  "html",
  "cssls",
  "jsonls",
  "eslint",
})

-- LspAttach autocmd for keymaps and features
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    -- Enable completion
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    -- Enable inlay hints
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    -- ESLint: auto-fix on save
    if client and client.name == "eslint" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.cmd("silent! EslintFixAll")
        end,
      })
    end
  end,
})

-- =========================
-- 7. KEYMAPS
-- =========================

local map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Buffer navigation
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- LSP navigation (standard g-prefix)
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- Diagnostics navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Completion
map("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })

-- Better escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Clear search highlight
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- <leader>e = Explorer
map("n", "<leader>e", ":Oil<CR>", { desc = "Explorer (Oil)" })

-- <leader>f = Find (fzf-lua)
map("n", "<leader>ff", require("fzf-lua").files, { desc = "Files" })
map("n", "<leader>fg", require("fzf-lua").live_grep, { desc = "Grep" })
map("n", "<leader>fw", require("fzf-lua").grep_cword, { desc = "Word under cursor" })
map("n", "<leader>fb", require("fzf-lua").buffers, { desc = "Buffers" })
map("n", "<leader>fr", require("fzf-lua").oldfiles, { desc = "Recent files" })
map("n", "<leader>fh", require("fzf-lua").help_tags, { desc = "Help" })
map("n", "<leader>fc", require("fzf-lua").commands, { desc = "Commands" })
map("n", "<leader>fk", require("fzf-lua").keymaps, { desc = "Keymaps" })
map("n", "<leader>f/", require("fzf-lua").lgrep_curbuf, { desc = "Grep current buffer" })

-- <leader>s = Symbols/Search (LSP-powered)
map("n", "<leader>sd", require("fzf-lua").diagnostics_document, { desc = "Document diagnostics" })
map("n", "<leader>sD", require("fzf-lua").diagnostics_workspace, { desc = "Workspace diagnostics" })
map("n", "<leader>ss", require("fzf-lua").lsp_document_symbols, { desc = "Document symbols" })
map("n", "<leader>sS", require("fzf-lua").lsp_workspace_symbols, { desc = "Workspace symbols" })

-- <leader>g = Git
map("n", "<leader>gs", require("fzf-lua").git_status, { desc = "Status" })
map("n", "<leader>gc", require("fzf-lua").git_commits, { desc = "Commits" })
map("n", "<leader>gb", require("fzf-lua").git_bcommits, { desc = "Buffer commits" })
map("n", "<leader>gB", require("fzf-lua").git_branches, { desc = "Branches" })

-- <leader>l = LSP actions
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format" })
map("n", "<leader>li", ":checkhealth lsp<CR>", { desc = "LSP info" })
map("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- <leader>x = Close/Delete
map("n", "<leader>x", ":bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>X", ":bdelete!<CR>", { desc = "Force close buffer" })

-- <leader>w = Window
map("n", "<leader>ws", ":split<CR>", { desc = "Horizontal split" })
map("n", "<leader>wv", ":vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>wc", ":close<CR>", { desc = "Close window" })
map("n", "<leader>wo", ":only<CR>", { desc = "Close other windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equal window sizes" })

-- <leader>m = Mason
map("n", "<leader>m", ":Mason<CR>", { desc = "Mason" })

-- =========================
-- 8. AUTOCOMMANDS
-- =========================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-create parent directories when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- =========================
-- 9. DIAGNOSTIC CONFIG
-- =========================
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- =========================
-- CHEATSHEET
-- =========================
--[[
INSTALL LSP SERVERS (run :Mason then press 'i' to install):
  - typescript-language-server (for JS/TS)
  - lua-language-server (for Lua)
  - pyright (for Python)
  - vscode-langservers-extracted (for HTML/CSS/JSON/ESLint)

NAVIGATION:
  <C-h/j/k/l>     Move between windows
  <Tab>/<S-Tab>   Next/previous buffer
  gd              Go to definition
  gr              Go to references
  K               Hover docs
  [d / ]d         Previous/next diagnostic
  [h / ]h         Previous/next git hunk

FIND (<leader>f):
  ff              Find files
  fg              Live grep
  fb              Buffers
  fr              Recent files

LSP (<leader>l):
  lr              Rename symbol
  la              Code action
  lf              Format

GIT (<leader>g + <leader>h):
  gs              Git status
  hs              Stage hunk
  hr              Reset hunk
]]

