-- Utility ====================================================================
local util = dofile('_scripts/util.lua')

local reflow = util.reflow
local is_blank = util.is_blank
local make_anchor = util.make_anchor
local get_help_tags = util.get_help_tags
local iter_noncode = util.iter_noncode
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
  -- Show more nested headers (useful for documentation pages)
  'toc-depth: 5',
}
vim.fn.writefile(metadata_lines, 'mini.nvim/_metadata.yml')

-- Help files =================================================================
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
  local bad_ranges = {}

  local replace_not_in_ranges = function(s, pat, repl)
    local res = s:gsub(pat, function(col, text)
      for _, range in ipairs(bad_ranges) do
        if range[1] <= col and col < range[2] then return end
      end
      return type(repl) == 'string' and string.format(repl, text) or repl(text)
    end)
    return res
  end

  local populate_bad_ranges = function(s)
    bad_ranges = {}
    -- Inline code
    s:gsub('`().-()`', function(from, to) table.insert(bad_ranges, { from, to }) end)
    -- Actual link (but not visible part!) of markdown link
    s:gsub('%b[]()%b()()', function(from, to) table.insert(bad_ranges, { from, to }) end)
  end

  local repl_link = function(m)
    -- Escape special markdown characters to be shown as is
    local link_name = m:gsub('[_*~$]', '\\%1')
    if tags[m] == nil then
      -- Escpe special characters to be usable inside markdown link
      local link_anchor = m:gsub('[)(]', '\\%1')
      return string.format('[%s](https://neovim.io/doc/user/helptag.html?tag=%s)', link_name, link_anchor)
    end

    return string.format('[%s](%s.qmd#%s)', link_name, tags[m], make_anchor(m))
  end

  local repl_right_anchor = function(m)
    -- Transform right anchor into a heading (for table of contents entry).
    -- Compute more natural title. Common tag->title transformations:
    -- - `*MiniAi*` -> "Module" ("Overview" is commonly used later as
    --   a 'MiniXxx-overview' tag). Both as title and anchor.
    -- - `*MiniAi.find_textobject()*` -> "find_textobject()"
    -- - `*MiniAi-builtin-textobjects*` -> "Builtin textobjects"
    -- - `*mini.nvim-disabling-recipes*` -> "Disabling recipes"
    -- - `:DepsAdd` -> ":DepsAdd"
    m = m:find('^Mini%w+$') ~= nil and 'Module' or m
    local text = m:match('^Mini%w+(%W.+)$') or m:match('^mini%.%w+(%W.+)$') or m
    local char_one, char_two = text:sub(1, 1), text:sub(2, 2)
    local title = char_one == '.' and text:sub(2)
      or (char_one == '-' and (char_two:upper() .. text:sub(3):gsub('%-', ' ')) or text)

    -- Preserve original tag as anchor for other converted links (coming from
    -- the help files) to work more naturally
    return string.format('### %s {#%s .help-syntax-right-anchor}\n', title, make_anchor(m))
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
    populate_bad_ranges(lines[i])

    -- `|xxx|` is used to add a a link to a tag anchor
    lines[i] = replace_not_in_ranges(lines[i], '()|(%S-)|', repl_link)
    -- - Recompute code ranges because adding links adds one
    populate_bad_ranges(lines[i])

    -- `<xxx>` is used to show keys and (often) table fields. Escape to not be
    -- treated as HTML tags. Do so before adding any custom HTML tags.
    lines[i] = replace_not_in_ranges(lines[i], '()<(%S-)>', '<span class="help-syntax-keys">\\<%s\\></span>')

    -- `{xxx}` is used to add special highlighting. Usually arguments.
    lines[i] = replace_not_in_ranges(lines[i], '(){(%S-)}', '<span class="help-syntax-special">{%s}</span>')

    -- `*xxx*` is used to add an anchor to a tag. Treat right aligned anchors
    -- as start of the section (adds to table of contents).
    lines[i] = lines[i]:gsub('^ +%*(.-)%*$', repl_right_anchor)
    lines[i] = replace_not_in_ranges(lines[i], '()%*(%S-)%*', repl_anchor)

    -- `Xxx ~` is used to add subsections within section denoted by ruler
    lines[i] = lines[i]:gsub('^(.+) ~$', repl_section_header)
  end

  reflow(lines)
end

local adjust_toc = function(lines)
  -- Transform Table Of Contents (entries like "aaa .... bbb ... ccc") into
  -- a markdown table with each part as a separate column.
  for i, l in iter_noncode(lines) do
    local is_toc_line = l:find('%s+%.%.%.+%s+') ~= nil
    if is_toc_line then
      -- Allow more than one column
      local line, n_repl = vim.trim(l):gsub('%s+%.%.%.+%s+', ' | ')
      lines[i] = '| ' .. line .. ' |'
      local n_col = n_repl + 1

      -- Prepend first TOC item with a (possibly crudely detected) header
      local header_parts = vim.split(vim.trim(lines[i - 1]), '   +')
      local is_blank_prev_line = header_parts[1] == '' and header_parts[2] == nil
      if is_blank_prev_line or #header_parts == n_col then
        header_parts = is_blank_prev_line and vim.fn['repeat']({ '' }, n_col) or header_parts
        local header = '| ' .. table.concat(header_parts, ' | ') .. ' |'
        -- Assume right most column is a link, so right align it.
        local separator = string.rep('|---', n_col) .. ':|'
        lines[i - 1] = '\n' .. header .. '\n' .. separator
      end
    end
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

local create_help = function()
  local help_tags = get_help_tags()

  local help_path = 'mini.nvim/doc'
  for file, _ in vim.fs.dir(help_path) do
    local basename = file:match('^(.+)%.txt$')
    if basename ~= nil then
      local in_path = vim.fs.joinpath(help_path, file)
      local lines = vim.fn.readfile(in_path)

      make_codeblocks(lines)
      adjust_rulers(lines)
      add_empty_lines(lines)
      add_help_syntax(lines, help_tags)
      adjust_toc(lines)
      adjust_alignment(lines)
      add_hierarchical_heading_anchors(lines)
      add_source_note(lines, 'mini.nvim')
      adjust_header_footer(lines, basename:gsub('%-', '.') .. ' documentation')

      local out_path = string.format('%s/%s.qmd', help_path, basename)
      vim.fn.writefile(lines, out_path)

      -- Remove '*.txt' file, as it is not needed for the site
      vim.fn.delete(in_path, '')
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
      replace_quote_alerts(lines)
      replace_help_links(lines)
      add_source_note(lines, 'mini.nvim')
      adjust_header_footer(lines, 'mini.' .. file:match('(%w+)%.md$'))
      add_doc_links(lines)

      vim.fn.writefile(lines, path)
    end
  end

  -- Main README
  local path = vim.fs.joinpath('mini.nvim/index.md')
  local lines = vim.fn.readfile(path)
  replace_quote_alerts(lines)
  replace_help_links(lines)
  add_source_note(lines, 'mini.nvim')
  adjust_header_footer(lines, 'mini.nvim')
  vim.fn.writefile(lines, path)
end

local _, err_msg_readmes = pcall(adjust_readmes)
if err_msg_readmes then io.write('Error during adjusting readmes:\n' .. err_msg_readmes) end

-- CHANGELOG ==================================================================
local adjust_changelog = function()
  local path = 'mini.nvim/CHANGELOG.md'
  local lines = vim.fn.readfile(path)

  add_source_note(lines, 'mini.nvim')
  add_hierarchical_heading_anchors(lines)

  vim.fn.writefile(lines, path)
end

local _, err_msg_changelog = pcall(adjust_changelog)
if err_msg_changelog then io.write('Error during adjusting changelog:\n' .. err_msg_changelog) end
