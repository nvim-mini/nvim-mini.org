-- Utility ====================================================================
local util = dofile('_scripts/util.lua')

local add_hierarchical_heading_anchors = util.add_hierarchical_heading_anchors
local add_source_note = util.add_source_note
local adjust_header_footer = util.adjust_header_footer
local replace_quote_alerts = util.replace_quote_alerts

-- Metadata ===================================================================
local metadata_lines = {
  -- Hide displaying the title as it is redundant and out of place
  'format:',
  '  html:',
  '    include-in-header:',
  '      - text: "<style> .quarto-title > h1.title { display: none } </style>"',
  'toc-depth: 5',
}
vim.fn.writefile(metadata_lines, 'MiniMax/_metadata.yml')

-- READMEs ====================================================================
local adjust_readmes = function()
  for _, rel_path in ipairs({ 'index.md', 'configs/index.md' }) do
    local path = vim.fs.joinpath('MiniMax', rel_path)
    local lines = vim.fn.readfile(path)

    replace_quote_alerts(lines)
    add_source_note(lines, 'MiniMax')
    local title = 'MiniMax' .. (vim.startswith(rel_path, 'configs/') and ' configs' or '')
    adjust_header_footer(lines, title)

    vim.fn.writefile(lines, path)
  end
end

local _, err_msg_readmes = pcall(adjust_readmes)
if err_msg_readmes then io.write('Error during adjusting readmes:\n' .. err_msg_readmes) end

-- CHANGELOG ==================================================================
local adjust_changelog = function()
  local path = 'MiniMax/CHANGELOG.md'
  local lines = vim.fn.readfile(path)

  add_source_note(lines, 'MiniMax')
  add_hierarchical_heading_anchors(lines)

  vim.fn.writefile(lines, path)
end

local _, err_msg_changelog = pcall(adjust_changelog)
if err_msg_changelog then io.write('Error during adjusting changelog:\n' .. err_msg_changelog) end

-- Configs ====================================================================
local configs_path = 'MiniMax/configs'
local diffs_path = 'MiniMax/configs/diffs'

-- Diffs ----------------------------------------------------------------------
local get_files_content = function(dir, rel_path)
  local path = vim.fs.joinpath(dir, rel_path)
  if vim.fn.filereadable(path) == 1 then return { [rel_path] = vim.fn.readblob(path) } end
  local res = {}
  for name, fs_type in vim.fs.dir(path, { depth = math.huge }) do
    local p = vim.fs.joinpath(rel_path, name)
    if fs_type == 'file' then res[p] = vim.fn.readblob(vim.fs.joinpath(dir, p)) end
  end
  return res
end

local get_union_fields = function(t1, t2)
  local keys = {}
  for k, _ in pairs(t1) do
    keys[k] = true
  end
  for k, _ in pairs(t2) do
    keys[k] = true
  end
  local res = vim.tbl_keys(keys)
  table.sort(res)
  return res
end

local append_diff_file_content = function(lines, f_content_from, f_content_to, rel_path)
  local diff_opts = { result_type = 'unified', algorithm = 'histogram' }
  local diff = vim.diff(f_content_from, f_content_to, diff_opts)
  diff = diff:gsub('\n\\ No newline at end of file', ''):gsub('\n+$', '')
  local anchor = rel_path:lower():gsub('[\\/]', '-')
  local title = string.format('#### %s {#%s}', rel_path, anchor)

  vim.list_extend(lines, { '', title, '' })
  if diff == '' then return vim.list_extend(lines, { 'No difference' }) end

  -- NOTE: Use custom `diffhunks` language because `diff` misinterprets removed
  -- Lua comments as file path (both start with `---`)
  vim.list_extend(lines, { '<details><summary>Diff</summary>', '', '```diffhunks' })
  vim.list_extend(lines, vim.split(diff, '\n'))
  vim.list_extend(lines, { '```', '', '</details>' })
end

local append_diff_content = function(lines, from, to, rel_path)
  local content_from = get_files_content(vim.fs.joinpath(configs_path, from), rel_path)
  local content_to = get_files_content(vim.fs.joinpath(configs_path, to), rel_path)
  for _, f in ipairs(get_union_fields(content_from, content_to)) do
    append_diff_file_content(lines, content_from[f] or '', content_to[f] or '', f)
  end
end

local append_diff = function(lines, from, to)
  append_diff_content(lines, from, to, 'init.lua')
  append_diff_content(lines, from, to, 'nvim-pack-lock.json')
  append_diff_content(lines, from, to, 'plugin')
  append_diff_content(lines, from, to, 'snippets')
  append_diff_content(lines, from, to, 'after')
end

local make_one_config_diff = function(from, to)
  local title = string.format('Moving from `%s` to `%s`', from, to)

  local from_link = string.format('[`%s`](../../%s/index.qmd)', from, from)
  local to_link = string.format('[`%s`](../../%s/index.qmd)', to, to)
  local lines = {
    '### ' .. title,
    '',
    string.format('This page shows changes when moving from config %s to config %s.', from_link, to_link),
    'They are broken down into per-file differences that are shown in the'
      .. ' [unified `diff` format](https://en.wikipedia.org/wiki/Diff#Unified_format).',
    'The suggested usage is to consult this page when updating from'
      .. string.format(' `%s` to `%s` to see what is new.', from, to),
    '',
    'In short:',
    '',
    '- Lines with `@` show line numbers of where the change is made.',
    string.format('- Lines with `-` are removed from `%s` config file.', from),
    string.format('- Lines with `+` are added into `%s` config file.', to),
  }

  append_diff(lines, from, to)
  add_source_note(lines, 'MiniMax')
  adjust_header_footer(lines, title)

  local path = vim.fs.joinpath(diffs_path, from .. '_' .. to)
  vim.fn.delete(path, 'rf')
  vim.fn.mkdir(path, 'p')
  vim.fn.writefile(lines, path .. '/index.qmd')
end

local make_config_diffs = function()
  vim.fn.delete(diffs_path, 'rf')
  vim.fn.mkdir(diffs_path, 'p')

  make_one_config_diff('nvim-0.10', 'nvim-0.11')
  make_one_config_diff('nvim-0.11', 'nvim-0.12')
end

local _, err_msg_config_diffs = pcall(make_config_diffs)
if err_msg_config_diffs then io.write('Error during making config diffs:\n' .. err_msg_config_diffs) end

-- Code -----------------------------------------------------------------------
local append_config_content
append_config_content = function(lines, config_name, rel_path)
  local path = vim.fs.joinpath(configs_path, config_name, rel_path)

  if vim.fn.isdirectory(path) == 1 then
    local entries = vim.fn.readdir(path)
    table.sort(entries)
    for _, f in ipairs(entries) do
      append_config_content(lines, config_name, vim.fs.joinpath(rel_path, f))
    end
    return
  end

  if vim.fn.filereadable(path) ~= 1 then return end

  local anchor = rel_path:lower():gsub('[\\/]', '-')
  local title = string.format('#### %s {#%s}', rel_path, anchor)
  local lang = vim.fn.fnamemodify(rel_path, ':e')

  vim.list_extend(lines, {
    '',
    title,
    '',
    '<details><summary>Code</summary>',
    '',
    '```' .. lang,
  })
  vim.list_extend(lines, vim.fn.readfile(path))
  vim.list_extend(lines, { '```', '', '</details>' })
end

local append_config = function(lines, config_name)
  append_config_content(lines, config_name, 'init.lua')
  append_config_content(lines, config_name, 'nvim-pack-lock.json')
  append_config_content(lines, config_name, 'plugin')
  append_config_content(lines, config_name, 'snippets')
  append_config_content(lines, config_name, 'after')
end

local adjust_configs = function()
  for name, fs_type in vim.fs.dir(configs_path) do
    if fs_type == 'directory' and name ~= 'diffs' then
      local title = string.format('MiniMax config `%s`', name)

      local lines = { '### ' .. title }

      append_config(lines, name)
      add_source_note(lines, 'MiniMax')
      adjust_header_footer(lines, title)

      local path = vim.fs.joinpath(configs_path, name)
      vim.fn.delete(path, 'rf')
      vim.fn.mkdir(path, 'p')
      vim.fn.writefile(lines, path .. '/index.qmd')
    end
  end
end

local _, err_msg_configs = pcall(adjust_configs)
if err_msg_configs then io.write('Error during adjusting configs:\n' .. err_msg_configs) end
