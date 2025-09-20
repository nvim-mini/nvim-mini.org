-- Tweak READMEs
-- Make video demos point to original source in a way that work with Quarto.
local replace_demo_link = function(lines)
  for i, l in ipairs(lines) do
    local link = l:match('^<%!%-%- Demo source: (%S+) %-%->')
    if link then
      lines[i] = string.format('![](%s?raw=true)', link)
      table.remove(lines, i + 1)
      return
    end
  end
end

local readmes_path = vim.fn.fnamemodify('mini.nvim/readmes', 'p')
for file, _ in vim.fs.dir(readmes_path) do
  if file:find('%.md$') ~= nil then
    local path = vim.fs.joinpath(readmes_path, file)
    local lines = vim.fn.readfile(path)
    replace_demo_link(lines)
    vim.fn.writefile(lines, path)
  end
end

vim.cmd('quit')
