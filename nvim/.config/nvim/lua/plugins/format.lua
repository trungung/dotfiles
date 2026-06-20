local M = {}

local utils = require('plugins.utils')
local conform_util = require('conform.util')

local function web_formatters(bufnr)
  if utils.has_oxc_project(bufnr) then
    return { 'oxfmt' }
  end
  if utils.has_biome_project(bufnr) then
    return { 'biome' }
  end
  if utils.has_prettier_project(bufnr) then
    return { 'prettierd', 'prettier', stop_after_first = true }
  end
  return {}
end

local function build_formatters_by_ft()
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

  return formatters_by_ft
end

function M.setup(map)
  require('conform').setup({
    formatters_by_ft = build_formatters_by_ft(),
    default_format_opts = {
      lsp_format = 'fallback',
    },
    format_on_save = function(bufnr)
      if utils.should_skip_buffer(bufnr) then
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

  if map then
    map('n', '<leader>cf', function()
      require('conform').format({ lsp_format = 'fallback', timeout_ms = 1200 })
    end, 'Format buffer')
  end
end

return M
