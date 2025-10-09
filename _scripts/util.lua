local M = {}

M.reflow = function(lines)
  local new_lines = vim.split(table.concat(lines, '\n'), '\n')
  for i, l in ipairs(new_lines) do
    lines[i] = l
  end
end

M.is_blank = function(x) return x:find('^%s*$') ~= nil end

M.make_anchor = function(x)
  -- Improve anchor for versions. This also removes any prerelease indicators.
  if x:find('^[Vv]ersion ') ~= nil then x = 'v' .. x:match('[%d%.]+') end

  -- Manual heading anchors in Pandoc (like "# Heading {#my-heading}") don't
  -- work with a lot of non-alphanumeric chars (like "(" / ")" / "'"). Remove
  -- them to sanitaize anchors.
  -- The `<xxx>` in anchor can be confused for HTML tag. Escape it.
  return (x:lower():gsub('[^%w%.%-_]', ''):gsub('%s', '-'):gsub('<(.-)>', '\\<%1\\>'))
end

M.get_help_tags = function(tags_path)
  tags_path = tags_path or '_deps/mini.nvim/doc/tags'
  if vim.uv.fs_stat(tags_path) == nil then vim.cmd('helptags _deps/mini.nvim/doc') end

  local tags = {}
  for _, l in ipairs(vim.fn.readfile(tags_path)) do
    local tag, basename = l:match('^(.-)\t(.-)%.txt\t')
    tags[tag] = basename
  end
  return tags
end

M.iter_noncode = function(lines)
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

M.add_hierarchical_heading_anchors = function(lines)
  local anchor_stack = {}
  for i, l in M.iter_noncode(lines) do
    -- Reuse already present anchor and other extra pandoc related data
    -- (like from right aligned tag heading with its own anchor and class).
    -- Anchors should only be present for the "top level" headings.
    local header_prefix, header_name, header_anchor, header_extra = l:match('^(#+)%s+(.-) {#([^%s}]+)(.*)}$')
    if header_anchor == nil then
      header_prefix, header_name = l:match('^(#+)%s+(.+)$')
      header_extra = ''
    end

    if header_prefix ~= nil and header_name ~= nil then
      header_anchor = header_anchor or M.make_anchor(header_name)

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
      lines[i] = string.format('%s %s {#%s%s}', header_prefix, header_name, anchor, header_extra)
    end
  end
end

M.add_source_note = function(lines)
  local msg = "_Generated from the `main` branch of 'mini.nvim'_"
  if lines[1]:find('align="center"') ~= nil then
    -- Center align if after center aligned element (i.e. top README image)
    table.insert(lines, 2, '<p align="center">' .. msg .. '</p>')
    table.insert(lines, 3, '')
  else
    table.insert(lines, 1, msg)
    table.insert(lines, 2, '')
  end
end

M.adjust_header_footer = function(lines, title)
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

M.replace_quote_alerts = function(lines)
  -- Quotes on GitHub can start with special "Alert" syntax for special render.
  -- The syntax is `> [!<kind>]`. Like `> [!NOTE]` or `> [!TIP]`.
  -- Quarto has similar thing but it is called callout blocks and the syntax
  -- is different. Thankfully, kinds are the same, just lowercase.
  --
  -- Sources:
  -- https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts
  -- https://quarto.org/docs/authoring/callouts.html#callout-types
  local allowed_kinds = {
    NOTE = true,
    TIP = true,
    IMPORTANT = true,
    WARNING = true,
    CAUTION = true,
  }

  local alert_start, alert_kind, alert_indent
  local n_repl, n_lines = 0, #lines
  for i, l in M.iter_noncode(lines) do
    if alert_start == nil then
      alert_indent, alert_kind = l:match('^(%s*)>%s+%[!(%w+)%]$')
      if allowed_kinds[alert_kind] ~= nil and M.is_blank(lines[i - 1] or '') then alert_start = i end
    else
      -- Remove quotes of the whole block until it ends.
      -- Accout for possible quote alert at last or second to last line.
      lines[i], n_repl = l:gsub('^%s*>%s+', alert_indent)
      if n_repl == 0 or i == n_lines then
        lines[alert_start] = string.format('%s::: {.callout-%s}', alert_indent, alert_kind:lower())
        lines[i] = n_repl == 0 and (alert_indent .. ':::\n' .. l) or (l .. '\n' .. alert_indent .. ':::')

        alert_start, alert_kind = nil, nil
      end
    end
  end

  M.reflow(lines)
end

return M
