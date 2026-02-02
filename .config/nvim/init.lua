-- =========================
-- Minimal Neovim 0.12 setup
-- =========================

-- Leader
vim.g.mapleader = " "

-- Basic options
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.smoothscroll = true
vim.opt.grepprg = "rg --vimgrep --no-messages --smart-case"

-- Plugins (native vim.pack)
vim.pack.add({
  "https://github.com/catppuccin/nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/lukas-reineke/indent-blankline.nvim",
  "https://github.com/folke/which-key.nvim",
})

-- Theme
require("catppuccin").setup({ transparent_background = true })
vim.cmd.colorscheme("catppuccin")

-- Gitsigns
require("gitsigns").setup({})

-- Oil
require("oil").setup({})

-- Treesitter
require("nvim-treesitter").setup({
  ensure_installed = { "lua", "javascript", "typescript", "python", "json", "html", "css" },
  auto_install = true,
  highlight = { enable = true },
})

-- Fuzzy finder
require("fzf-lua").setup({ winopts = { preview = { layout = "vertical" } } })

-- Indent guides
require("ibl").setup({})

-- Which-key (shows keymaps when you press leader)
require("which-key").setup({})

-- LSP
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "angularls" },
})

vim.lsp.config("ts_ls", {})
vim.lsp.config("angularls", {})

-- =========================
-- Keymaps (grouped by purpose)
-- =========================

-- <leader>e = Explorer
vim.keymap.set("n", "<leader>e", ":Oil<CR>", { silent = true, desc = "Explorer" })

-- <leader>f = Find
vim.keymap.set("n", "<leader>ff", require("fzf-lua").files, { desc = "Files" })
vim.keymap.set("n", "<leader>fg", require("fzf-lua").live_grep, { desc = "Grep" })
vim.keymap.set("n", "<leader>fb", require("fzf-lua").buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", require("fzf-lua").oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fh", require("fzf-lua").help_tags, { desc = "Help" })
vim.keymap.set("n", "<leader>fd", require("fzf-lua").diagnostics_document, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fs", require("fzf-lua").lsp_document_symbols, { desc = "Symbols" })

-- <leader>g = Git
vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Status" })
vim.keymap.set("n", "<leader>gd", ":Gvdiffsplit<CR>", { desc = "Diff" })
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Commit" })
vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Push" })
vim.keymap.set("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Log" })
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Blame" })

-- <leader>d = Diagnostics
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous" })
vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float, { desc = "Show" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "List all" })

-- <leader>l = LSP
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Action" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format" })
vim.keymap.set("n", "<leader>li", ":LspInfo<CR>", { desc = "Info" })
vim.keymap.set("n", "<leader>lm", ":Mason<CR>", { desc = "Mason" })

-- <leader>b = Buffers
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous" })
vim.keymap.set("n", "<leader>bx", ":bdelete<CR>", { desc = "Close" })

-- Quick buffer switching (no leader)
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- LSP navigation (these are standard, keep them short)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })

-- LSP keymaps on attach (for buffer-specific completion)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.o.completeopt = "menu,menuone,noinsert"
      if vim.lsp.completion and vim.lsp.completion.enable then
        vim.lsp.completion.enable(true, client.id, args.buf)
      end
    end
  end,
})

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})
