-- Help files =================================================================
local get_help_tags = function()
  local tags_path = '_deps/mini.nvim/doc/tags'
  if vim.uv.fs_stat(tags_path) == nil then vim.cmd('helptags _deps/mini.nvim/doc') end

  local tags = {}
  for _, l in ipairs(vim.fn.readfile(tags_path)) do
    local tag, basename = l:match('^(.-)\t(.-)%.txt\t')
    tags[tag] = basename
  end
  return tags
end

local reflow = function(lines)
  local new_lines = vim.split(table.concat(lines, '\n'), '\n')
  for i, l in ipairs(new_lines) do
    lines[i] = l
  end
end

local is_blank = function(x) return x:find('^%s*$') ~= nil end

local make_codeblocks = function(lines)
  local codeblock_start, cur_indent
  local empty_at_codeblock_start = {}
  for i, l in ipairs(lines) do
    if codeblock_start == nil and l:find(' *>%w*$') then
      codeblock_start, cur_indent = i, string.rep(' ', 200)

      -- Most of code blocks are padded with empty/blank line at the top for
      -- better readability in built-in help. This makes it worse in markdown.
      if is_blank(lines[i + 1] or 'non-blank') then empty_at_codeblock_start[i + 1] = true end
    elseif codeblock_start ~= nil then
      -- Try detecting codeblock end
      if l:find('^ *<$') ~= nil then
        -- Adjust code fences indent for proper rendering inside lists
        lines[codeblock_start] = lines[codeblock_start]:gsub(' *>(%w*)$', '\n\n' .. cur_indent .. '```%1')
        lines[i] = cur_indent .. '```\n'
        codeblock_start = nil
      else
        -- Compute indent when directly inside code block
        local prefix = l:match('^(%s*)%S')
        cur_indent = (prefix ~= nil and prefix:len() < cur_indent:len()) and prefix or cur_indent
      end
    end
  end

  for i = #lines, 1, -1 do
    if empty_at_codeblock_start[i] then table.remove(lines, i) end
  end

  reflow(lines)
end

local iter_noncode = function(lines)
  local n = #lines
  local f = function(_, i)
    if i >= n then return nil end
    i = i + 1
    if lines[i]:find('^ *```%w*$') == nil then return i, lines[i] end
    for j = i + 1, n do
      if lines[j]:find('^ *```$') ~= nil and j < n then return j + 1, lines[j + 1] end
    end
    return nil
  end
  return f, {}, 0
end

local adjust_rulers = function(lines)
  for i, l in iter_noncode(lines) do
    if l:find('^=+$') ~= nil or l:find('^-+$') ~= nil then lines[i] = '---\n' end
  end
  reflow(lines)
end

local add_empty_lines = function(lines)
  -- Add empty lines in places where it improves markdown parsing
  for i, l in iter_noncode(lines) do
    -- Before list item for it to be properly recognized as such
    -- Before `{xxx} ...` which is an argument description from 'mini.doc'
    lines[i] = l:gsub('^( *%- )', '\n%1'):gsub('^( *%b{})', '\n%1')

    -- After section title `Title ~` (if not already) for better parsing
    if l:find(' ~$') ~= nil and (lines[i + 1] or ''):find('^%s*$') == nil then lines[i] = lines[i] .. '\n' end
  end

  reflow(lines)
end

local add_help_syntax = function(lines)
  local code_ranges = {}
  local replace_not_in_code_ranges = function(s, pat, repl_format)
    local res = s:gsub(pat, function(col, text)
      for _, range in ipairs(code_ranges) do
        if range[1] <= col and col < range[2] then return end
      end
      local repl = string.format(repl_format, text)
      return repl
    end)
    return res
  end

  for i, l in iter_noncode(lines) do
    -- Collect `xxx` ranges within line to not act inside of them
    code_ranges = {}
    l:gsub('`().-()`', function(from, to) table.insert(code_ranges, { from, to }) end)

    -- `<xxx>` is used to show keys and (often) table fields.
    -- Escape to not be treated as HTML tags.
    lines[i] = replace_not_in_code_ranges(l, '()<(%S-)>', '<span class="help-syntax-keys">\\<%s\\></span>')

    -- `{xxx}` is used to add special highlighting. Usually arguments.
    lines[i] = replace_not_in_code_ranges(lines[i], '(){(%S-)}', '<span class="help-syntax-special">{%s}</span>')

    -- `Xxx ~` is used to add highlighted section start
    -- TODO: Decide maybe to treat it like a markdown header?
    lines[i] = lines[i]:gsub('^(.+) ~$', '<span class="help-syntax-section">%1</span>')
  end
end

local adjust_alignment = function(lines)
  -- Replace manually right and center aligned elements with dedicated tags
  for i, l in iter_noncode(lines) do
    local right_tag_anchor = l:match('^ +(%*.-%*)$')
    if right_tag_anchor ~= nil then lines[i] = '<p align="right">' .. right_tag_anchor .. '</p>' end

    local center_signature = l:match('^ +(`.-`%b())$') or l:match('^ +(`.-`)$')
    if center_signature ~= nil then lines[i] = '<p align="center">' .. center_signature .. '</p>' end
  end
end

local replace_tags_with_links = function(lines, tags)
  local repl_anchor = function(m)
    local text = m:match('^%*(.+)%*$')
    if not tags[text] then return m end
    -- `<a name="%s"></a>` adds actual anchor; `class="" data-anchor-id=""`
    -- adds "chain" icon revealed on hover to get the link.
    -- Alternative is to have `<a name="%s" href="%s">%s</a>`, but it shows
    -- tags as plain links. May be acceptable, though.
    return string.format('<a name="%s"></a><b class="anchored" data-anchor-id="%s">%s</b>', text, text, text)
  end

  local repl_link = function(m)
    local text = m:match('^|(.+)|$')
    -- Escpe special characters to be usable inside markdown link
    local text_escaped = text:gsub('[)(]', '\\%1')
    return tags[text] ~= nil and string.format('[`%s`](%s.qmd#%s)', text, tags[text], text_escaped)
      or string.format('[`%s`](https://neovim.io/doc/user/helptag.html?tag=%s)', text, text_escaped)
  end

  for i, l in iter_noncode(lines) do
    lines[i] = l:gsub('%*.-%*', repl_anchor):gsub('|[%w%p]-|', repl_link)
  end
end

local adjust_header_footer = function(lines, title)
  -- Add informative header for better search
  table.insert(lines, 1, '---')
  table.insert(lines, 2, string.format('title: "%s"', title))
  table.insert(lines, 3, '---')
  table.insert(lines, 4, '')

  -- Remove modeline
  if lines[#lines]:find('^ vim:') then
    lines[#lines] = nil
    lines[#lines] = nil
  end
end

local create_help = function()
  local help_tags = get_help_tags()

  local help_path = 'mini.nvim/doc'
  for file, _ in vim.fs.dir(help_path) do
    local basename = file:match('^(.+)%.txt$')
    if basename ~= nil then
      local lines = vim.fn.readfile(vim.fs.joinpath(help_path, file))

      make_codeblocks(lines)
      adjust_rulers(lines)
      add_empty_lines(lines)
      add_help_syntax(lines)
      adjust_alignment(lines)
      replace_tags_with_links(lines, help_tags)
      adjust_header_footer(lines, basename:gsub('%-', '.') .. ' documentation')

      local out_path = string.format('%s/%s.qmd', help_path, basename)
      vim.fn.writefile(lines, out_path)
    end
  end
end

local _, err_msg_help = pcall(create_help)
if err_msg_help then io.write('Error during help creation:\n' .. err_msg_help) end

-- READMEs ====================================================================
local replace_demo_link = function(lines)
  for i, l in ipairs(lines) do
    -- Make video demos point to original source in a way that work with Quarto
    local link = l:match('^<%!%-%- Demo source: (%S+) %-%->')
    if link then
      lines[i] = string.format('![](%s?raw=true)', link)
      table.remove(lines, i + 1)
      return
    end
  end
end

local replace_help_links = function(lines)
  for i, l in ipairs(lines) do
    lines[i] = l:gsub('%(%.%./doc/(.-)%.txt%)', '(../doc/%1.qmd)'):gsub('%(doc/(.-)%.txt%)', '(doc/%1.qmd)')
  end
end

local add_tag_links = function(lines)
  local help_tags = get_help_tags()
  local repl = function(m)
    local code = m:match('^`:h (.-)`$') or m:match('^`(.-)`$')
    if help_tags[code] == nil then return m end
    return string.format('[%s](../doc/%s.qmd#%s)', m, help_tags[code], code)
  end
  for i, l in ipairs(lines) do
    lines[i] = l:gsub('`.-`', repl)
  end
end

local adjust_readmes = function()
  -- Module READMEs
  local readmes_path = 'mini.nvim/readmes'
  for file, _ in vim.fs.dir(readmes_path) do
    if file:find('%.md$') ~= nil then
      local path = vim.fs.joinpath(readmes_path, file)
      local lines = vim.fn.readfile(path)

      replace_demo_link(lines)
      replace_help_links(lines)
      add_info_header(lines, 'mini.' .. file:match('(%w+)%.md$'))
      add_tag_links(lines)

      vim.fn.writefile(lines, path)
    end
  end

  -- Main README
  local path = vim.fs.joinpath('mini.nvim/index.md')
  local lines = vim.fn.readfile(path)
  add_info_header(lines, 'mini.nvim')
  replace_help_links(lines)
  vim.fn.writefile(lines, path)
end

local _, err_msg_readmes = pcall(adjust_readmes)
if err_msg_readmes then io.write('Error during adjusting readmes:\n' .. err_msg_readmes) end

-- CHANGELOG ==================================================================
local parse_md_line = function(line, state)
  -- Detect code blocks and don't detect headers inside of them
  local is_codeblock_edge = line:find('^%s*```%S*%s*$') ~= nil
  if is_codeblock_edge then
    state.is_in_codeblock = not state.is_in_codeblock
    return line
  end
  if state.is_in_codeblock then return line end

  -- Detect header
  local header_prefix, header_name = line:match('^(#+)%s+(.+)$')
  if not (header_prefix ~= nil and header_name ~= nil) then return line end

  -- Sanitize header for cleaner anchor
  if vim.startswith(header_name, 'Version') then header_name = 'v' .. header_name:match('[%d%.]+') end
  header_name = header_name:lower()

  -- Modify stack
  local header_level = header_prefix:len()
  state.header_stack[header_level] = header_name
  for n = header_level + 1, #state.header_stack do
    state.header_stack[n] = nil
  end

  -- Add anchor
  local anchor = table.concat(state.header_stack, '-'):gsub('%s+', '-')
  return string.format('%s {#%s}', line, anchor)
end

local adjust_changelog = function()
  local path = 'mini.nvim/CHANGELOG.md'
  local lines = vim.fn.readfile(path)
  local state = { header_stack = {}, is_in_codeblock = false }
  for i, l in ipairs(lines) do
    lines[i] = parse_md_line(l, state)
  end
  vim.fn.writefile(lines, path)
end

local _, err_msg_changelog = pcall(adjust_changelog)
if err_msg_changelog then io.write('Error during adjusting changelog:\n' .. err_msg_changelog) end

-- Finish
vim.cmd('quit')
