-- Utility ====================================================================
local reflow = function(lines)
  local new_lines = vim.split(table.concat(lines, '\n'), '\n')
  for i, l in ipairs(new_lines) do
    lines[i] = l
  end
end

local is_blank = function(x) return x:find('^%s*$') ~= nil end

local make_anchor = function(x)
  -- Improve anchor for versions. This also removes any prerelease indicators.
  if x:find('^[Vv]ersion ') ~= nil then x = 'v' .. x:match('[%d%.]+') end

  -- Manual heading anchors in Pandoc (like "# Heading {#my-heading}") don't
  -- work with a lot of non-alphanumeric chars (like "(" / ")" / "'"). Remove
  -- them to sanitaize anchors.
  -- The `<xxx>` in anchor can be confused for HTML tag. Escape it.
  return (x:lower():gsub('[^%w%.%-_]', ''):gsub('%s', '-'):gsub('<(.-)>', '\\<%1\\>'))
end

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

local make_codeblocks = function(lines)
  local codeblock_start, cur_indent
  local empty_at_codeblock_start = {}
  for i, l in ipairs(lines) do
    local is_codeblock_start = l:find(' +>%w*$') ~= nil or l:find('^>%w*$') ~= nil
    if codeblock_start == nil and is_codeblock_start then
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

local add_help_syntax = function(lines, tags)
  local code_ranges = {}

  local replace_not_in_code_ranges = function(s, pat, repl)
    local res = s:gsub(pat, function(col, text)
      for _, range in ipairs(code_ranges) do
        if range[1] <= col and col < range[2] then return end
      end
      return type(repl) == 'string' and string.format(repl, text) or repl(text)
    end)
    return res
  end

  local populate_code_ranges = function(s)
    code_ranges = {}
    s:gsub('`().-()`', function(from, to) table.insert(code_ranges, { from, to }) end)
  end

  local repl_link = function(m)
    -- Escpe special characters to be usable inside markdown link
    if tags[m] == nil then
      local text_escaped = m:gsub('[)(]', '\\%1')
      return string.format('[`%s`](https://neovim.io/doc/user/helptag.html?tag=%s)', m, text_escaped)
    end

    return string.format('[`%s`](%s.qmd#%s)', m, tags[m], make_anchor(m))
  end

  local repl_right_anchor = function(m)
    -- Transform right anchor into a heading (for table of contents entry).
    -- Compute more natural title. Common tag->title transformations:
    -- - `*MiniAi*` -> "Overview"
    -- - `*MiniAi.find_textobject()*` -> "find_textobject()"
    -- - `*MiniAi-builtin-textobjects*` -> "Builtin textobjects"
    -- - `:DepsAdd` -> ":DepsAdd"
    local text = m:find('^Mini%w+$') ~= nil and 'Overview' or (m:match('^Mini%w+(%W.+)$') or m)
    local char_one, char_two = text:sub(1, 1), text:sub(2, 2)
    local title = char_one == '.' and text:sub(2)
      or (char_one == '-' and (char_two:upper() .. text:sub(3):gsub('%-', ' ')) or text)

    -- Preserve original tag as anchor for other links to work more naturally
    return string.format('### %s {#%s}\n', title, make_anchor(m))
  end

  local repl_anchor = function(m)
    if not tags[m] then return m end
    -- `<a name="%s" href="%s"></a>` adds actual anchor and acts as a link to
    -- itself for easier copy (make it bold to visually show this).
    local anchor = make_anchor(m)
    return string.format('<a name="%s" href="%s.qmd#%s"><b>%s</b></a>', anchor, tags[m], anchor, m)
  end

  local repl_section_header = function(m)
    -- Treat "raw" section headers "Title ~" as "# Title ~"
    local prefix = m:sub(1, 1) == '#' and '' or '# '
    return '###' .. prefix .. m .. '\n'
  end

  for i, _ in iter_noncode(lines) do
    -- Collect `xxx` ranges within line to not act inside of them
    populate_code_ranges(lines[i])

    -- `|xxx|` is used to add a a link to a tag anchor
    lines[i] = replace_not_in_code_ranges(lines[i], '()|([%w%.-_<>%(%)]-)|', repl_link)
    -- - Recompute code ranges because adding links adds one
    populate_code_ranges(lines[i])

    -- `<xxx>` is used to show keys and (often) table fields. Escape to not be
    -- treated as HTML tags. Do so before adding any custom HTML tags.
    lines[i] = replace_not_in_code_ranges(lines[i], '()<(%S-)>', '<span class="help-syntax-keys">\\<%s\\></span>')

    -- `{xxx}` is used to add special highlighting. Usually arguments.
    lines[i] = replace_not_in_code_ranges(lines[i], '(){(%S-)}', '<span class="help-syntax-special">{%s}</span>')

    -- `*xxx*` is used to add an anchor to a tag. Treat right aligned anchors
    -- as start of the section (adds to table of contents).
    lines[i] = lines[i]:gsub('^ +%*(.-)%*$', repl_right_anchor)
    lines[i] = replace_not_in_code_ranges(lines[i], '()%*(%S-)%*', repl_anchor)

    -- `Xxx ~` is used to add subsections within section denoted by ruler
    lines[i] = lines[i]:gsub('^(.+) ~$', repl_section_header)
  end

  reflow(lines)
end

local adjust_alignment = function(lines)
  for i, l in iter_noncode(lines) do
    -- Transform center aligned signature or section "name"
    local center_signature = l:match('^ +(`.-`%b())$') or l:match('^ +(`.-`)$')
    if center_signature ~= nil then lines[i] = '<p align="center">' .. center_signature .. '</p>' end
  end
end

local add_hierarchical_heading_anchors = function(lines)
  local anchor_stack = {}
  for i, l in iter_noncode(lines) do
    -- Reuse already present anchor (like from right aligned tag heading)
    -- They should only be present for the "top level" headings.
    local header_prefix, header_name, header_anchor = l:match('^(#+)%s+(.-) {#(.-)}$')
    if header_anchor == nil then
      header_prefix, header_name = l:match('^(#+)%s+(.+)$')
    end

    if header_prefix ~= nil and header_name ~= nil then
      header_anchor = header_anchor or make_anchor(header_name)

      -- Modify stack
      local header_level = header_prefix:len()
      anchor_stack[header_level] = header_anchor
      -- NOTE: Take into account that `anchor_stack` can have holes if headings
      -- are not in consecutive levels
      for k, _ in pairs(anchor_stack) do
        if k > header_level then anchor_stack[k] = nil end
      end

      -- Add anchor
      local keys = vim.tbl_keys(anchor_stack)
      table.sort(keys)
      local anchor = table.concat(vim.tbl_map(function(k) return anchor_stack[k] end, keys), '-')
      lines[i] = string.format('%s %s {#%s}', header_prefix, header_name, anchor)
    end
  end
end

local adjust_header_footer = function(lines, title)
  -- Add informative header for better search
  table.insert(lines, 1, '---')
  table.insert(lines, 2, string.format('title: "%s"', title))
  table.insert(lines, 3, 'toc-depth: 5')
  table.insert(lines, 4, '---')
  table.insert(lines, 5, '')

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
      add_help_syntax(lines, help_tags)
      adjust_alignment(lines)
      add_hierarchical_heading_anchors(lines)
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

local add_doc_links = function(lines)
  local help_tags = get_help_tags()
  local repl = function(m)
    local code = m:match('^`:h (.-)`$') or m:match('^`(.-)`$')
    if help_tags[code] == nil then return m end
    return string.format('[%s](../doc/%s.qmd#%s)', m, help_tags[code], make_anchor(code))
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
      adjust_header_footer(lines, 'mini.' .. file:match('(%w+)%.md$'))
      add_doc_links(lines)

      vim.fn.writefile(lines, path)
    end
  end

  -- Main README
  local path = vim.fs.joinpath('mini.nvim/index.md')
  local lines = vim.fn.readfile(path)
  adjust_header_footer(lines, 'mini.nvim')
  replace_help_links(lines)
  vim.fn.writefile(lines, path)
end

local _, err_msg_readmes = pcall(adjust_readmes)
if err_msg_readmes then io.write('Error during adjusting readmes:\n' .. err_msg_readmes) end

-- CHANGELOG ==================================================================
local adjust_changelog = function()
  local path = 'mini.nvim/CHANGELOG.md'
  local lines = vim.fn.readfile(path)

  add_hierarchical_heading_anchors(lines)

  vim.fn.writefile(lines, path)
end

local _, err_msg_changelog = pcall(adjust_changelog)
if err_msg_changelog then io.write('Error during adjusting changelog:\n' .. err_msg_changelog) end

-- Finish
vim.cmd('quit')
