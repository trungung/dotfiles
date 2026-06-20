local M = {}

local function get_buffer_name(bufnr)
  bufnr = bufnr or 0
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return nil
  end
  return filename
end

local function read_file(path)
  if not path or vim.fn.filereadable(path) == 0 then
    return ''
  end
  return table.concat(vim.fn.readfile(path), '\n')
end

local function find_upward(names, start)
  return vim.fs.find(names, { upward = true, path = start })[1]
end

function M.package_json_content(bufnr)
  local filename = get_buffer_name(bufnr)
  if not filename then
    return ''
  end
  local pkg = find_upward({ 'package.json' }, vim.fs.dirname(filename))
  return read_file(pkg)
end

function M.has_oxc_project(bufnr)
  local content = M.package_json_content(bufnr)
  if content == '' then
    return false
  end
  return content:match('"oxfmt"') ~= nil
    or content:match('"oxlint"') ~= nil
    or content:match('"oxc"') ~= nil
end

function M.has_biome_project(bufnr)
  local filename = get_buffer_name(bufnr)
  if not filename then
    return false
  end

  local dir = vim.fs.dirname(filename)
  if find_upward({ 'biome.json', 'biome.jsonc' }, dir) then
    return true
  end

  local content = M.package_json_content(bufnr)
  return content:match('"@biomejs/biome"') ~= nil
    or content:match('"biome"') ~= nil
end

function M.has_prettier_project(bufnr)
  local filename = get_buffer_name(bufnr)
  if not filename then
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

  local content = M.package_json_content(bufnr)
  if content == '' then
    return false
  end
  return content:match('"prettier"%s*:') ~= nil
    or content:match('"prettier"') ~= nil
    or content:match('"prettierd"') ~= nil
end

function M.should_skip_buffer(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].buftype ~= '' then
    return true
  end

  local filename = get_buffer_name(bufnr)
  if not filename then
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

return M
