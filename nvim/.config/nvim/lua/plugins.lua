-- Neovim 0.12 built-in package manager
vim.g.copilot_no_tab_map = false -- keep <Tab> for Copilot ghost text accept

vim.pack.add({
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/Saghen/blink.cmp",
	"https://github.com/github/copilot.vim",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/sainnhe/gruvbox-material",
	"https://github.com/esmuellert/codediff.nvim",
}, { load = true })

local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- ── theme ──────────────────────────────────────────────────────────────────

vim.g.gruvbox_material_background = "hard"
vim.cmd("colorscheme gruvbox-material")

-- ── ui ─────────────────────────────────────────────────────────────────────

local wk = require("which-key")
wk.setup({})
wk.add({
	{ "<leader>c", group = "Code" },
	{ "<leader>f", group = "Find" },
	{ "<leader>h", group = "Git Hunks" },
})

require("mini.move").setup({})
require("mini.pairs").setup({})
require("mini.statusline").setup({})
require("mini.indentscope").setup({
	draw = { animation = require("mini.indentscope").gen_animation.none() },
	options = { indent_at_cursor = false },
})

-- ── explorer ───────────────────────────────────────────────────────────────

require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})
map("n", "<leader>e", "<Cmd>Oil<CR>", "Explorer (Oil)")

-- ── git ────────────────────────────────────────────────────────────────────

require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		local bmap = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
		end

		bmap("]h", gs.next_hunk, "Next hunk")
		bmap("[h", gs.prev_hunk, "Prev hunk")
		bmap("<leader>hs", gs.stage_hunk, "Stage hunk")
		bmap("<leader>hr", gs.reset_hunk, "Reset hunk")
		bmap("<leader>hp", gs.preview_hunk, "Preview hunk")
		bmap("<leader>hb", function()
			gs.blame_line({ full = true })
		end, "Blame line")
	end,
})

-- ── fuzzy finder ───────────────────────────────────────────────────────────
-- Configuration optimized to utilize default global/local gitignores automatically.
-- No need for large redundant lists of directories inside Lua.

local fzf_options = {
	files = {
		fd_opts = "--color=never --type f --hidden --follow --exclude .git",
	},
	grep = {
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob '!.git/*'",
	},
	keymap = {
		fzf = {
			["alt-j"] = "down",
			["alt-k"] = "up",
		},
	},
}

local fzf_configured = false
local function fzf_lua()
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		vim.notify("fzf-lua unavailable: " .. fzf, vim.log.levels.ERROR)
		return nil
	end
	if not fzf_configured then
		fzf.setup(fzf_options)
		fzf_configured = true
	end
	return fzf
end

map("n", "<leader>ff", function()
	local fzf = fzf_lua()
	if not fzf then
		return
	end
	fzf.files({
		hidden = true,
		no_ignore = true,
	})
end, "Find files")
map("n", "<leader>fg", function()
	local fzf = fzf_lua()
	if fzf then
		fzf.live_grep()
	end
end, "Live grep")
map("n", "<leader>fb", function()
	local fzf = fzf_lua()
	if fzf then
		fzf.buffers()
	end
end, "Find buffers")
map("n", "<leader>fo", function()
	local fzf = fzf_lua()
	if fzf then
		fzf.oldfiles()
	end
end, "Recent files")

-- ── completion ─────────────────────────────────────────────────────────────

require("luasnip.loaders.from_vscode").lazy_load()
require("blink.cmp").setup({
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "lua" }, -- native binary unavailable; lua is fine
	completion = {
		menu = { auto_show = false }, -- open manually with <C-space>
		ghost_text = { enabled = false }, -- Copilot handles inline ghost text
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	keymap = {
		preset = "default",
		["<Tab>"] = false, -- reserved for Copilot
		["<S-Tab>"] = false,
	},
	cmdline = { enabled = false },
})

-- ── formatting ─────────────────────────────────────────────────────────────

-- rules live in plugins/format.lua; falls back to LSP when no formatter found
require("plugins.format").setup(map)

-- ── lsp ────────────────────────────────────────────────────────────────────

local lsp_servers = {
	"lua_ls",
	"ts_ls",
	"html",
	"cssls",
	"tailwindcss",
	"angularls",
	"jsonls",
	"yamlls",
	"bashls",
	"pyright",
	"gopls",
	"eslint",
	"biome",
}

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = lsp_servers,
	automatic_enable = false,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
})

vim.lsp.config("angularls", {
	-- attach only when an Angular workspace is present
	workspace_required = true,
})

vim.lsp.config("eslint", {
	-- attach only when a project config file is present
	root_markers = {
		"eslint.config.js",
		"eslint.config.cjs",
		"eslint.config.mjs",
		"eslint.config.ts",
		"eslint.config.cts",
		"eslint.config.mts",
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yml",
		".eslintrc.yaml",
		".eslintrc.json",
	},
})

vim.lsp.config("biome", {
	-- attach only when a biome config is present
	root_markers = { "biome.json", "biome.jsonc" },
	-- match UTF-16 used by ts_ls/tailwindcss to avoid position offset bugs
	capabilities = {
		general = { positionEncodings = { "utf-16" } },
	},
})

vim.lsp.enable(lsp_servers)

-- ── treesitter ─────────────────────────────────────────────────────────────

local treesitter_languages = {
	-- web
	"javascript",
	"typescript",
	"tsx",
	"json",
	"html",
	"css",
	-- backend
	"python",
	"go",
	"gomod",
	"gowork",
	"gosum",
	-- nvim / config
	"lua",
	"vim",
	"vimdoc",
	"bash",
	"yaml",
	"toml",
	"markdown",
	"markdown_inline",
	"query",
}

if vim.fn.executable("tree-sitter") == 1 then
	require("nvim-treesitter").install(treesitter_languages)
else
	vim.schedule(function()
		vim.notify("tree-sitter CLI not found; install tree-sitter-cli, then run :TSUpdate", vim.log.levels.WARN)
	end)
end

-- enable treesitter highlighting for any buffer with a parser
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user.treesitter", { clear = true }),
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

-- ── quick help ─────────────────────────────────────────────────────────────

local function open_tutor_keys()
	local lines = {
		"Neovim Quick Keys (VS Code-friendly)",
		"",
		"Find",
		"  <leader>ff  Find files",
		"  <leader>fg  Live grep",
		"  <leader>fb  Buffers",
		"  <leader>fo  Recent files",
		"",
		"Code",
		"  gd          Go to definition",
		"  gr          Find references",
		"  K           Hover docs",
		"  <leader>ca  Code action",
		"  <leader>rn  Rename symbol",
		"  <leader>cd  Line diagnostics",
		"  <leader>cf  Format buffer",
		"",
		"Git / Explorer",
		"  ]h / [h     Next/prev git hunk",
		"  <leader>hs  Stage hunk",
		"  <leader>hr  Reset hunk",
		"  <leader>e   Explorer (Oil)",
		"",
		"Completion",
		"  <Tab>       Accept Copilot ghost text",
		"  <C-space>   Open Blink completion menu",
		"  <C-n>/<C-p> Select next/previous Blink item",
		"  <C-y>       Confirm Blink completion item",
		"",
		"Close this help with q or <Esc>.",
	}

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "markdown"

	local max_line = 0
	for _, line in ipairs(lines) do
		max_line = math.max(max_line, vim.fn.strdisplaywidth(line))
	end

	local width = math.max(52, math.min(max_line + 4, vim.o.columns - 4))
	local height = math.max(12, math.min(#lines + 2, vim.o.lines - 4))
	local row = math.max(0, math.floor((vim.o.lines - height) / 2 - 1))
	local col = math.max(0, math.floor((vim.o.columns - width) / 2))

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = row,
		col = col,
		title = " NvimTutorKeys ",
		title_pos = "center",
	})
	vim.wo[win].wrap = false

	vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
	vim.keymap.set("n", "<Esc>", "<Cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
end

vim.api.nvim_create_user_command("NvimTutorKeys", open_tutor_keys, {
	desc = "Show quick keymap help for daily editing flow",
})
map("n", "<leader>?", "<Cmd>NvimTutorKeys<CR>", "Keymap quick help")
