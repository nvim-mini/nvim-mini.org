-- Create logo files based on the font files in 'font/' subdirectory.
-- To generate, run `nvim --clean -c 'source generate.lua' -c 'quit!'`
-- from 'logo-2/' directory. Requires `imagemagick`.
local make_logo = function(output_basename, letter_filenames)
  -- Main "pixel art" file
  local cmd_pixels = { 'magick', 'font/prefix.gif' }
  local letter_files = vim.tbl_map(function(l) return string.format('font/%s.gif', l) end, letter_filenames)
  vim.list_extend(cmd_pixels, letter_files)
  local output_pixels = output_basename .. '_pixels.gif'
  vim.list_extend(cmd_pixels, { '+append', output_pixels })
  vim.system(cmd_pixels):wait()

  -- README logo
  --stylua: ignore
  local cmd_readme = {
    'magick', output_pixels,
    '-filter', 'point',
    -- NOTE: Use 105 because it is a multiple of 7 (height of "pixel" version)
    '-resize', '^1x105',
    output_basename .. '_readme.png',
  }
  vim.system(cmd_readme):wait()

  -- GitHub social preview
  --stylua: ignore
  local cmd_github = {
    'magick', output_pixels,
    '-filter', 'point',
    '-background', 'none',
    '-resize', '1280x^1',
    '-gravity', 'center',
    '-extent', '1280x640',
    output_basename .. '_github.png',
  }
  vim.system(cmd_github):wait()
end

local mini_modules = {
  'ai',
  'align',
  'animate',
  'base16',
  'basics',
  'bracketed',
  'bufremove',
  'clue',
  'cmdline',
  'colors',
  'comment',
  'completion',
  'cursorword',
  'deps',
  'diff',
  'doc',
  'extra',
  'files',
  'fuzzy',
  'git',
  'hipatterns',
  'hues',
  'icons',
  'indentscope',
  'input',
  'jump',
  'jump2d',
  'keymap',
  'map',
  'misc',
  'move',
  'notify',
  'operators',
  'pairs',
  'pick',
  'sessions',
  'snippets',
  'splitjoin',
  'starter',
  'statuscolumn',
  'statusline',
  'surround',
  'tabline',
  'test',
  'trailspace',
  'visits',
}

for _, name in ipairs(mini_modules) do
  make_logo('logo-' .. name, vim.split(name, ''))
end
make_logo('logo-nvim', { 'n-neovim', 'v', 'i', 'm' })
