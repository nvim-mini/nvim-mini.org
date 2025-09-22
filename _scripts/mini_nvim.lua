-- Help files =================================================================
-- TODO: convert help files into markdown

-- READMEs ====================================================================
local readmes_path = vim.fs.abspath('mini.nvim/readmes')

-- Adjust demos ---------------------------------------------------------------
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

local adjust_demos = function()
  for file, _ in vim.fs.dir(readmes_path) do
    if file:find('%.md$') ~= nil then
      local path = vim.fs.joinpath(readmes_path, file)
      local lines = vim.fn.readfile(path)
      replace_demo_link(lines)
      vim.fn.writefile(lines, path)
    end
  end
end

local ok_demo_links = pcall(adjust_demos)

-- CHANGELOG ==================================================================
-- TODO: Add persistent anchors to 'CHANGELOG.md' headers

-- Search =====================================================================
-- TODO: Explore the ways to improve default search. Like:
-- - Adjust "title" in generated 'search.json' instead of all READMEs having
--   "MINI" as title.

vim.cmd('quit')
