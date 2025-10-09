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

  return lines
end

local append_config = function(lines, config_name)
  append_config_content(lines, config_name, 'init.lua')
  append_config_content(lines, config_name, 'plugin')
  append_config_content(lines, config_name, 'snippets')
  append_config_content(lines, config_name, 'after')
end

local adjust_configs = function()
  for name, fs_type in vim.fs.dir(configs_path) do
    if fs_type == 'directory' then
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
