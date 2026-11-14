-- Generate MINI logos with custom vector font
--
-- How to use:
-- - `:source` this file.
-- - Ensure that cwd is at the project root (not `logo-3` subdirectory).
-- - Execute relevant global function(s).
--   Like for the new module: `:lua _G.logo_mini_module('xxx')`.
--   This will create/update all relevant files in 'logo-3' directory.
--   Requires `imagemagick`.

-- Font =======================================================================
-- Each letter is drawn on a 24x48 grid. There should be at least some stroke
-- on all four sides (top, bottom, left, right).
--
-- Each letter is drawn with (usually one) `<path>` that has `d="M0,0 ..."`.
-- It always starts at the top left corner and draws its shape using relative
-- instructions. Replacing `M0,0` with a relevant top left coordinate moves
-- the letter to it.
local font = {
  ['a'] = '<path d="M0,0 m0,48 l0,-36 a12,12,0,0,1,24,0 l0,36 m-24,-24 l24,0"/>',
  ['b'] = '<path d="M0,0 l0,48 l12,0 a12,12,0,0,0,0,-24 a12,12,0,0,0,0,-24 l-12,0 m0,24 l12,0"/>',
  ['c'] = '<path d="M0,0 m24,12 a12,12,0,0,0,-24,0 l0,24 a12,12,0,0,0,24,0"/>',
  ['d'] = '<path d="M0,0 l0,48 l12,0 a12,12,0,0,0,12,-12 l0,-24 a12,12,0,0,0,-12,-12 l-12,0"/>',
  ['e'] = '<path d="M0,0 m24,0 l-24,0 l0,48 l24,0 m-24,-24 l16,0"/>',
  ['f'] = '<path d="M0,0 m24,0 l-24,0 l0,48 m0,-24 l16,0"/>',
  ['g'] = '<path d="M0,0 m24,12 a12,12,0,0,0,-24,0 l0,24 a12,12,0,0,0,24,0 l0,-12 l-8,0"/>',
  ['h'] = '<path d="M0,0 l0,48 m0,-24 l24,0 m0,-24 l0,48"/>',
  ['i'] = '<path d="M0,0 l24,0 m-12,0 l0,48 m-12,0 l24,0"/>',
  ['j'] = '<path d="M0,0 m24,0 l0,36 a12,12,0,0,1,-24,0"/>',
  ['k'] = '<path d="M0,0 l0,48 m6,-24 l18,-24 m-18,24 l18,24"/>',
  ['l'] = '<path d="M0,0 l0,48 l24,0"/>',
  ['m'] = '<path d="M0,0 m0,48 l0,-48 l12,24 l12,-24 l0,48"/>',
  ['n'] = '<path d="M0,0 m0,48 l0,-48 l24,48 l0,-48"/>',
  ['o'] = '<path d="M0,0 m24,12 a12,12,0,0,0,-24,0 l0,24 a12,12,0,0,0,24,0 l0,-24"/>',
  ['p'] = '<path d="M0,0 m0,48 l0,-48 l12,0 a12,12,0,0,1,0,24 l-12,0"/>',
  ['q'] = '<path d="M0,0 m24,12 a12,12,0,0,0,-24,0 l0,24 a12,12,0,0,0,24,0 l0,-24 m0,36 l-12,-12"/>',
  ['r'] = '<path d="M0,0 m0,48 l0,-48 l12,0 a12,12,0,0,1,0,24 l-12,0 m6,0 l18,24"/>',
  ['s'] = '<path d="M0,0 m24,12 a12,12,0,1,0,-12,12 a12,12,0,1,1,-12,12"/>',
  ['t'] = '<path d="M0,0 l24,0 m-12,0 l0,48"/>',
  ['u'] = '<path d="M0,0 l0,36 a12,12,0,0,0,24,0 l0,-36"/>',
  ['v'] = '<path d="M0,0 l12,48 l12,-48"/>',
  ['w'] = '<path d="M0,0 l0,48 l12,-24 l12,24 l0,-48"/>',
  ['x'] = '<path d="M0,0 l24,48 m-24,0 l24,-48"/>',
  ['y'] = '<path d="M0,0 l12,24 l12,-24 m-12,24 l0,24"/>',
  ['z'] = '<path d="M0,0 l24,0 l-24,48 l24,0"/>',
  ['0'] = '<path d="M0,0 m24,12 a12,12,0,0,0,-24,0 l0,24 a12,12,0,0,0,24,0 l0,-24 m-12,24 l0,-24"/>',
  ['1'] = '<path d="M0,0 l12,0 l0,48 m-12,0 l24,0"/>',
  ['2'] = '<path d="M0,0 m0,12 a12,12,0,1,1,21.6,7.2 l-21.6,28.8 l24,0"/>',
  ['3'] = '<path d="M0,0 m0,12 a12,12,0,1,1,12,12 a12,12,0,1,1,-12,12"/>',
  ['4'] = '<path d="M0,0 m24,48 l0,-48 l-24,36 l24,0"/>',
  ['5'] = '<path d="M0,0 m24,0 l-24,0 l0,24 l12,0 a12,12,0,1,1,0,24 l-12,0"/>',
  ['6'] = '<path d="M0,0 m24,12 a12,12,0,0,0,-24,0 l0,24 a12,12,0,1,1,12,12 a12,12,0,0,1,-12,-12"/>',
  ['7'] = '<path d="M0,0 l24,0 l-12,48"/>',
  ['8'] = '<path d="M0,0 m0,12 a12,12,0,1,1,12,12 a12,12,0,0,1,-12,-12 m0,24 a12,12,0,1,1,12,12 a12,12,0,0,1,-12,-12"/>',
  ['9'] = '<path d="M0,0 m0,36 a12,12,0,0,0,24,0 l0,-24 a12,12,0,1,0,-12,12 a12,12,0,0,0,12,-12"/>',
  ['.'] = '<path d="M0,0 m12,48 a3,3,0,1,1,3,-3 a3,3,0,0,1,-3,3"/>',

  -- Special letter parts
  ['n_1'] = '<path d="M0,0 m0,48 l0,-48"/>',
  ['n_2'] = '<path d="M0,0 l24,48 l0,-48"/>',
}

-- Varying stroke width gives different font proportions following this logic:
-- - Drawing on edges visually adds half stroke width on each side.
-- - The proportions are (24/w + 1) by (48/w+1). For example
--     - w=12 -> 3x5
--     - w=10 -> 3.4x5.8 (in between 3x5 and 4x7)
--     - w=8  -> 4x7
--     - w=6  -> 5x9
local w = 10

-- When computing dimensions and spacing, the general idea is to have outer
-- padding and gaps between letter be equal to the stroke width. Those count
-- from where the stroke color actually ends, not the stroke center. It means:
-- - ViewBox offset = -1.5*w
-- - Width for n cols  = n*(24 + w) + (n-1)*w + 2*w = 24*n + (2n+1)*w
-- - Height for m rows = m*(48 + w) + (m-1)*w + 2*w = 48*m + (2m+1)*w
-- - Letter offset (top left of offset letter - top left or reference letter):
--     - Horizontal = 24 + 0.5*w + w + 0.5*w = 24 + 2*w
--     - Vertical   = 48 + 0.5*w + w + 0.5*w = 48 + 2*w
local view_offset = 1.5 * w
local letter_offset = 2 * w
_G.get_dims = function(n_col, n_row)
  local width = 24 * n_col + (2 * n_col + 1) * w
  local height = 48 * n_row + (2 * n_row + 1) * w
  return width, height
end

-- Colors come from the new 'minischeme' variant (done with 'mini.hues')
local colors = {
  bg = '#081823',
  grey = '#91937D',
  red = '#FFC0C4',
  orange = '#FCC9A0',
  yellow = '#E0D699',
  green = '#B4E3B5',
  cyan = '#94E6E5',
  azure = '#A1DDFF',
  blue = '#C8CDFF',
  purple = '#F0C3F2',
  tree_green = '#3D8B44',
  tree_brown = '#504600',
  tree_red = '#DE1100',
  hat_red = '#DE1100',
  hat_white = '#E0E0E0',
}

-- Helpers for common actions
local move = function(path, hor, ver) return (path:gsub('M0,0', 'M' .. hor .. ',' .. ver)) end
local set_stroke = function(path, color) return (path:gsub('/>', ' stroke="' .. color .. '"/>')) end
local set_fill = function(path, fill) return (path:gsub('/>', ' fill="' .. fill .. '"/>')) end
local set_color = function(path, color) return color == nil and path or set_stroke(set_fill(path, color), color) end
local scale = function(path, mul)
  local f = function(n)
    local res = mul * tonumber(n)
    return res == math.floor(res) and tostring(res) or string.format('%.1f', res)
  end
  local res = path:gsub('([lm])([%-%d%.]+),([%-%d%.]+)', function(t, x, y) return t .. f(x) .. ',' .. f(y) end)
  res = res:gsub(
    'a([%-%d%.]+),([%-%d%.]+),([01],[01],[01]),([%-%d%.]+),([%-%d%.]+)',
    function(rx, ry, mid, x, y) return string.format('a%s,%s,%s,%s,%s', f(rx), f(ry), mid, f(x), f(y)) end
  )
  return res
end

local make_header = function(n_col, n_row)
  local width, height = get_dims(n_col, n_row)
  local svg = '<svg version="1.1" '
    .. string.format('width="%d" height="%d"', width, height)
    .. string.format(' viewBox="-%d -%d %d %d"', view_offset, view_offset, width, height)
    .. ' xmlns="http://www.w3.org/2000/svg">'
  local g = string.format('<g stroke-width="%d" ', w)
    .. 'stroke-linecap="round" stroke-linejoin="round" '
    .. string.format('fill="%s">', colors.bg)
  return { svg, '  ' .. g }
end

local adjust_dimensions = function(lines, f_adjust)
  local box_in = { lines[1]:match('viewBox="([-%d]+) ([-%d]+) ([-%d]+) ([-%d]+)"') }
  local box = f_adjust(vim.tbl_map(tonumber, box_in))
  local off_x, off_y, width, height = unpack(box)

  lines[1] = lines[1]:gsub('width=".-"', string.format('width="%d"', width))
  lines[1] = lines[1]:gsub('height=".-"', string.format('height="%d"', height))
  lines[1] = lines[1]:gsub('viewBox=".-"', string.format('viewBox="%d %d %d %d"', off_x, off_y, width, height))
  lines[3] = lines[3]:gsub('x=".-"', string.format('x="%d"', off_x))
  lines[3] = lines[3]:gsub('y=".-"', string.format('y="%d"', off_y))
end

local make_bg_rect = function()
  local off = view_offset
  return string.format('<rect x="-%d" y="-%d" width="100%%" height="100%%"/>', off, off)
end

_G.show_font = function()
  local lines = make_header(9, 4)
  local append = function(indent, l) table.insert(lines, string.rep(' ', indent) .. l) end

  append(4, make_bg_rect())

  append(4, string.format('<g stroke="%s">', colors.yellow))
  local off_col, off_row = 48 + letter_offset, 24 + letter_offset
  for i, char in ipairs(vim.split('abcdefghijklmnopqrstuvwxyz0123456789', '')) do
    local row, col = (i - 1) % 9, math.floor((i - 1) / 9)
    append(6, '<!-- ' .. char:upper() .. ' --> ' .. move(font[char], row * off_row, col * off_col))
  end
  append(4, '</g>')

  -- Save '*.svg'
  vim.fn.writefile(lines, 'logo-3/font.svg')
end

-- Helpers ====================================================================
local with_azure_prefix = function(prefix_lines, suffix_lines)
  local n_prefix = #prefix_lines
  local lines = make_header(n_prefix + #suffix_lines, 1)
  local append = function(indent, l) table.insert(lines, string.rep(' ', indent) .. l) end

  append(4, make_bg_rect())

  -- Prefix
  local off = 24 + letter_offset
  append(4, string.format('<g stroke="%s">', colors.azure))
  for i, l in ipairs(prefix_lines) do
    append(6, move(l, (i - 1) * off, 0))
  end
  append(4, '</g>')

  -- Suffix
  append(4, string.format('<g stroke="%s">', colors.yellow))
  for i, l in ipairs(suffix_lines) do
    append(6, move(l, (n_prefix - 1 + i) * off, 0))
  end
  append(4, '</g>')

  -- Close header tags
  append(2, '</g>')
  append(0, '</svg>')

  return lines
end

local make_social_png = function(path, opts)
  -- NOTE: Use 1200x630 even for GitHub (although it recommends 1280x640) as
  -- otherwise social preview on other site crops left and right. Often to
  -- the point of cutting parts of letters away.
  local default_opts = { resize = '1200x^1', extent = '1200x630', output = path:gsub('%.svg$', '_github.png') }
  opts = vim.tbl_extend('force', default_opts, opts or {})
  -- Convert `basename.svg` to `basename.png`
  --stylua: ignore
  local cmd_github = {
    'magick', 'mogrify',
    '-format', 'png',
    '-density', '300',
    '-background', 'none',
    '-resize', opts.resize,
    '-gravity', 'center',
    '-extent', opts.extent,
    path,
  }
  vim.system(cmd_github):wait()

  -- Rename `basename.png` to `basename_github.png`
  local tmp_png = path:gsub('%.svg$', '.png')
  if tmp_png ~= opts.output then vim.uv.fs_rename(tmp_png, opts.output) end
end

-- Christmas helpers ==========================================================
-- Four ray star
local make_star = function(size, color)
  local path = '<path d="M0,0 m100,0 l-75,25 l-25,75 l-25,-75 l-75,-25 l75,-25 l25,-75 l25,75 l75,25"/>'
  return set_color(scale(path, 0.01 * size), color)
end

-- Three lines connecting opposite hexagon verticies
local make_snowflake = function(size, color)
  local path = '<path d="M0,0 m0,100 l0,-200 m87,50 l-174,100 m0,-100 l174,100"/>'
  return set_color(scale(path, 0.01 * size), color)
end

local make_circle = function(size, color)
  local path = '<path d="M0,0 m0,100 a100,100,0,0,1,0,-200 a100,100,0,0,1,0,200"/>'
  return set_color(scale(path, 0.01 * size), color)
end

local make_decor_ball = function(color)
  -- NOTE: imitate a thing that holds the ball on a vertical wire that goes
  -- outside of a viewBox
  local top = '<path d="M0,0 l4,0 l0,-12 l-8,0 l0,12 l4,0 l0,-200"/>'
  return set_color(top, colors.grey) .. ' ' .. make_circle(10, color)
end

local make_tree = function(height)
  -- Final dimensions: 50x100
  local bg = '<path d="M0,0 l25,0 l0,100 l-50,0 l0,-100 l25,0"/>'
  local tree = '<path d="M0,0 l15,30 l-10,0 l15,30 l-10,0 l15,30 l-50,0 l15,-30 l-10,0 l15,-30 l-10,0 l15,-30"/>'
  local trunk = '<path d="M0,0 m0,90 l5,0 l0,10 l-10,0 l0,-10 l5,0"/>'
  local ribbon_1 = '<path d="M0,0 m11,20 a11,3,0,0,1,-22,0"/>'
  local ribbon_2 = '<path d="M0,0 m16,50 a16,4,0,0,1,-32,0"/>'
  local ribbon_3 = '<path d="M0,0 m21,80 a21,5,0,0,1,-42,0"/>'

  local parts = {
    -- Ensure clean background, as it overlaps with the middle dot
    set_color(bg, colors.bg),
    set_color(trunk, colors.tree_brown),
    set_color(tree, colors.tree_green),
    set_fill(set_stroke(ribbon_1, colors.tree_red), 'none'),
    set_fill(set_stroke(ribbon_2, colors.tree_red), 'none'),
    set_fill(set_stroke(ribbon_3, colors.tree_red), 'none'),
  }
  return scale(table.concat(parts, ' '), 0.01 * height)
end

local make_hat = function()
  local red = '<path d="M0,0 m25,-5 a15,10,0,0,0,-50,10 a15,15,0,0,1,25,-5"/>'
  local pompom = '<path d="M0,0 m-20,5 a5,5,0,0,0,-10,0 a5,5,0,0,0,10,0"/>'
  local bottom = '<path d="M0,0 m-5,1 a50,10,0,0,0,30,-6" stroke-width="10"/>'

  local parts = {
    set_color(red, colors.hat_red),
    set_color(pompom, colors.hat_white),
    set_color(bottom, colors.hat_white),
  }
  return table.concat(parts, ' ')
end

-- 'mini.nvim' ================================================================
local with_azure_mini_prefix = function(suffix_lines)
  local prefix_lines = {
    '<!-- M --> ' .. font.m,
    '<!-- I --> ' .. font.i,
    '<!-- N --> ' .. font.n,
    '<!-- I --> ' .. font.i,
    '<!-- . --> ' .. font['.'],
  }
  return with_azure_prefix(prefix_lines, suffix_lines)
end

_G.logo_mini_nvim = function()
  -- Construct svg content
  local suffix_lines = {
    '<!-- N --> ' .. set_stroke(font.n_1, colors.cyan) .. ' ' .. set_stroke(font.n_2, colors.green),
    '<!-- V --> ' .. font.v,
    '<!-- I --> ' .. font.i,
    '<!-- M --> ' .. font.m,
  }
  local lines = with_azure_mini_prefix(suffix_lines)

  -- Save
  local out = 'logo-3/logo-mini-nvim.svg'
  vim.fn.writefile(lines, out)
  make_social_png(out)

  -- Christmas variant
  -- - Adjust dimensions
  local f_adjust = function(d)
    -- off_x, off_y, width, height
    return { d[1] - math.floor(1.618 * 24), d[2] - 48, d[3] + 2 * math.floor(1.618 * 24), d[4] + math.floor(1.618 * 48) }
  end
  adjust_dimensions(lines, f_adjust)

  -- - Add decorations
  local decor = function(path, row, col) return '  ' .. move(path, row, col) end
  local decor_lines = {
    '<!-- Stars -->',
    string.format('<g stroke-width="%d" stroke="%s" fill="%s">', 1, colors.yellow, colors.yellow),
    decor(make_star(10), 188, -20),
    decor(make_star(7), -40, 0),
    decor(make_star(6), 30, 75),
    decor(make_star(6), 300, 75),
    decor(make_star(7), 410, -35),
    '</g>',
    '<!-- Snowflakes -->',
    string.format('<g stroke-width="%d" stroke="%s" fill="%s">', 2, colors.azure, colors.azure),
    decor(make_snowflake(2), -40, 50),
    decor(make_snowflake(5), -35, 75),
    decor(make_snowflake(7), -30, -35),
    decor(make_snowflake(4), -25, 25),
    decor(make_snowflake(2), -15, -15),
    decor(make_snowflake(2), 0, 70),
    decor(make_snowflake(4), 30, -25),
    decor(make_snowflake(2), 40, -45),
    decor(make_snowflake(2), 60, -20),
    decor(make_snowflake(2), 65, 75),
    decor(make_snowflake(2), 95, -20),
    decor(make_snowflake(2), 100, 70),
    decor(make_snowflake(2), 115, -40),
    decor(make_snowflake(3), 130, 80),
    decor(make_snowflake(3), 135, -20),
    decor(make_snowflake(2), 165, -15),
    decor(make_snowflake(2), 170, 75),
    decor(make_snowflake(2), 188, -50),
    decor(make_snowflake(3), 210, -25),
    decor(make_snowflake(5), 215, 70),
    decor(make_snowflake(2), 240, -15),
    decor(make_snowflake(2), 245, 75),
    decor(make_snowflake(5), 260, -40),
    decor(make_snowflake(2), 275, 65),
    decor(make_snowflake(2), 280, -20),
    decor(make_snowflake(2), 325, 70),
    decor(make_snowflake(2), 330, -20),
    decor(make_snowflake(2), 340, -45),
    decor(make_snowflake(2), 355, 65),
    decor(make_snowflake(3), 360, -20),
    decor(make_snowflake(3), 380, 75),
    decor(make_snowflake(2), 395, -15),
    decor(make_snowflake(6), 400, 35),
    decor(make_snowflake(2), 410, 70),
    decor(make_snowflake(4), 415, 10),
    '</g>',
    '<!-- Decoration balls -->',
    string.format('<g stroke-width="%d">', 1),
    decor(make_decor_ball(colors.yellow), 0, -40),
    decor(make_decor_ball(colors.orange), 75, -35),
    decor(make_decor_ball(colors.red), 150, -40),
    decor(make_decor_ball(colors.purple), 225, -40),
    decor(make_decor_ball(colors.blue), 300, -35),
    decor(make_decor_ball(colors.azure), 375, -40),
    '</g>',
    '<!-- Tree -->',
    string.format('<g stroke-width="%d">', 2),
    -- NOTE: Align top and bottom with letters
    decor(make_tree(48 + w - 2), 188, -0.5 * w + 2),
    '</g>',
  }

  local indent = string.rep(' ', 4)
  for i = 1, #decor_lines do
    table.insert(lines, #lines - 1, indent .. decor_lines[i])
  end

  -- - Save
  local out_christmas = 'logo-3/logo-mini-nvim_christmas.svg'
  vim.fn.writefile(lines, out_christmas)
  make_social_png(out_christmas)
end

_G.logo_mini_module = function(name)
  -- Construct svg content
  local suffix_lines = {}
  for _, l in ipairs(vim.split(name, '')) do
    table.insert(suffix_lines, string.format('<!-- %s --> %s', l:upper(), font[l]))
  end
  local lines = with_azure_mini_prefix(suffix_lines)

  -- Save
  local out = 'logo-3/logo-mini-module-' .. name .. '.svg'
  vim.fn.writefile(lines, out)
  make_social_png(out)
end

-- MINI =======================================================================
-- The idea is to have a square view with a text in a center that also
-- organically fits in the inscribed circle:
-- - Use two stroke widths for outer padding and gaps.
-- - Add extra horizontal outer padding for the square view.
-- - Height for 2 cols: 48*2 + (2*2+1)*w + 3*w = 96 + 8*w
-- - Width is equal to height.
-- - ViewBox offset:
--     - Horizontal = -1.5*w - w - 24 = -2.5*w - 24 (the `-24` to compensate for
--       horizontal padding to make width equal to height).
--     - Vertical   = -1.5*w - w = -2.5*w.
-- - Letter offset:
--     - Horizontal = 24 + 3*w
--     - Vertical   = 48 + 3*w
-- - Center of the circle = 0.5*height + ViewBox-offset-{horiz,vert}:
--     - 48 + 4*w - 2.5*w - 24 = 24 + 1.5*w
--     - 48 + 4*w - 2.5*w      = 48 + 1.5*w
_G.logo_mini = function()
  local height = 96 + 8 * w
  local offset_hor = 2.5 * w + 24
  local offset_ver = 2.5 * w

  local lines = make_header(2, 2)
  local append = function(indent, l) table.insert(lines, string.rep(' ', indent) .. l) end

  append(4, make_bg_rect())

  -- - Adjust dimensions
  lines[1] = lines[1]:gsub('width=".-"', 'width="' .. height .. '"')
  lines[1] = lines[1]:gsub('height=".-"', 'height="' .. height .. '"')
  local viewbox = string.format('-%d -%d %d %d', offset_hor, offset_ver, height, height)
  lines[1] = lines[1]:gsub('viewBox=".-"', 'viewBox="' .. viewbox .. '"')
  lines[3] = lines[3]:gsub('x=".-"', 'x="-' .. offset_hor .. '"')
  lines[3] = lines[3]:gsub('y=".-"', 'y="-' .. offset_ver .. '"')

  -- Content
  local off_hor = 24 + 3 * w
  local off_ver = 48 + 3 * w
  append(4, '<!-- M --> ' .. set_stroke(move(font.m, 0 * off_hor, 0 * off_ver), colors.azure))
  append(4, '<!-- I --> ' .. set_stroke(move(font.i, 1 * off_hor, 0 * off_ver), colors.azure))
  append(4, '<!-- N --> ' .. set_stroke(move(font.n, 0 * off_hor, 1 * off_ver), colors.yellow))
  append(4, '<!-- I --> ' .. set_stroke(move(font.i, 1 * off_hor, 1 * off_ver), colors.yellow))

  -- - Close header tags
  append(2, '</g>')
  append(0, '</svg>')

  -- Save
  local out_mini = 'logo-3/logo-mini.svg'
  local out_mini_png = 'logo-3/logo-mini.png'
  local out_mini_social = 'logo-3/logo-mini_social.png'
  vim.fn.writefile(lines, out_mini)
  make_social_png(out_mini, { resize = '^1x630', output = out_mini_social })
  -- NOTE: Create this last since `magic mogrify -format png ...` from previous
  -- steps uses `logo-mini.png` as a temporary file name
  make_social_png(out_mini, { resize = '1000x1000', extent = '1000x1000', output = out_mini_png })

  local lines_circle = vim.deepcopy(lines)
  local cx = 0.5 * height - offset_hor
  local cy = 0.5 * height - offset_ver
  lines_circle[3] = string.format('    <circle cx="%d" cy="%d" r="50%%"/>', cx, cy)

  local out_mini_circle = 'logo-3/logo-mini_circle.svg'
  local out_mini_circle_png = 'logo-3/logo-mini_circle.png'
  vim.fn.writefile(lines_circle, out_mini_circle)
  make_social_png(out_mini_circle, { resize = '1000x1000', extent = '1000x1000', output = out_mini_circle_png })

  -- Christmas variant
  -- - Add decorations
  local decor = function(path, row, col) return '  ' .. move(path, row, col) end
  local decor_lines = {
    '<!-- Stars -->',
    string.format('<g stroke-width="%d" stroke="%s" fill="%s">', 1, colors.yellow, colors.yellow),
    decor(make_star(10), -30, 35),
    decor(make_star(10), 100, 25),
    '</g>',
    '<!-- Hat -->',
    string.format('<g stroke-width="%d">', 5, colors.yellow, colors.yellow),
    decor(make_hat(), 0, 0),
    '</g>',
    '<!-- Snowflakes -->',
    string.format('<g stroke-width="%d" stroke="%s" fill="%s">', 2, colors.azure, colors.azure),
    decor(make_snowflake(3), -40, -10),
    decor(make_snowflake(5), -35, 70),
    decor(make_snowflake(5), -30, 130),
    decor(make_snowflake(7), -25, 100),
    decor(make_snowflake(7), 100, 95),
    decor(make_snowflake(5), 105, 65),
    decor(make_snowflake(5), 110, -5),
    decor(make_snowflake(5), 110, 125),
    '</g>',
  }

  local indent = string.rep(' ', 4)
  for i = 1, #decor_lines do
    table.insert(lines, #lines - 1, indent .. decor_lines[i])
  end

  -- - Save
  local out_christmas = 'logo-3/logo-mini_christmas.svg'
  local out_christmas_png = 'logo-3/logo-mini_christmas.png'
  local out_christmas_social = 'logo-3/logo-mini_christmas_social.png'
  vim.fn.writefile(lines, out_christmas)
  make_social_png(out_christmas, { resize = '^1x630', output = out_christmas_social })
  -- NOTE: Create this last since `magic mogrify -format png ...` from previous
  -- steps uses `logo-mini.png` as a temporary file name
  make_social_png(out_christmas, { resize = '1000x1000', extent = '1000x1000', output = out_christmas_png })
end

-- MiniMax ====================================================================
_G.logo_minimax = function()
  local lines = make_header(7, 1)
  local append = function(indent, l) table.insert(lines, string.rep(' ', indent) .. l) end

  append(4, make_bg_rect())

  -- Prefix
  local off = 24 + letter_offset
  append(4, string.format('<g stroke="%s">', colors.yellow))
  append(6, '<!-- M --> ' .. move(font.m, 0 * off, 0))
  append(6, '<!-- I --> ' .. move(font.i, 1 * off, 0))
  append(6, '<!-- N --> ' .. move(font.n, 2 * off, 0))
  append(6, '<!-- I --> ' .. move(font.i, 3 * off, 0))
  append(4, '</g>')

  -- Suffix
  append(4, string.format('<g stroke="%s">', colors.azure))
  append(6, '<!-- M --> ' .. move(font.m, 4 * off, 0))
  append(6, '<!-- A --> ' .. move(font.a, 5 * off, 0))
  append(6, '<!-- X --> ' .. move(font.x, 6 * off, 0))
  append(4, '</g>')

  -- Close header tags
  append(2, '</g>')
  append(0, '</svg>')

  -- Save
  local out = 'logo-3/logo-minimax.svg'
  vim.fn.writefile(lines, out)
  make_social_png(out)

  -- Christmas variant
  -- - Adjust dimensions
  local f_adjust = function(d)
    -- off_x, off_y, width, height
    return { d[1] - math.floor(1.618 * 24), d[2] - 48, d[3] + 2 * math.floor(1.618 * 24), d[4] + math.floor(1.618 * 48) }
  end
  adjust_dimensions(lines, f_adjust)

  -- - Add decorations
  local decor = function(path, row, col) return '  ' .. move(path, row, col) end
  local decor_lines = {
    '<!-- Stars -->',
    string.format('<g stroke-width="%d" stroke="%s" fill="%s">', 1, colors.yellow, colors.yellow),
    decor(make_star(7), -40, 0),
    decor(make_star(6), 30, 75),
    decor(make_star(6), 300, 75),
    decor(make_star(7), 315, 25),
    '</g>',
    '<!-- Snowflakes -->',
    string.format('<g stroke-width="%d" stroke="%s" fill="%s">', 2, colors.azure, colors.azure),
    decor(make_snowflake(2), -40, 50),
    decor(make_snowflake(5), -35, 75),
    decor(make_snowflake(7), -30, -35),
    decor(make_snowflake(4), -25, 25),
    decor(make_snowflake(2), -15, -15),
    decor(make_snowflake(2), 0, 70),
    decor(make_snowflake(4), 30, -25),
    decor(make_snowflake(2), 40, -45),
    decor(make_snowflake(2), 60, -20),
    decor(make_snowflake(2), 65, 75),
    decor(make_snowflake(2), 95, -20),
    decor(make_snowflake(2), 100, 70),
    decor(make_snowflake(2), 115, -40),
    decor(make_snowflake(3), 130, 80),
    decor(make_snowflake(3), 135, -20),
    decor(make_snowflake(2), 165, -15),
    decor(make_snowflake(2), 170, 75),
    decor(make_snowflake(2), 188, -50),
    decor(make_snowflake(3), 210, -25),
    decor(make_snowflake(5), 215, 70),
    decor(make_snowflake(2), 240, -15),
    decor(make_snowflake(2), 245, 75),
    decor(make_snowflake(5), 260, -40),
    decor(make_snowflake(2), 275, 65),
    decor(make_snowflake(2), 280, -20),
    decor(make_snowflake(2), 320, 55),
    decor(make_snowflake(3), 320, 0),
    decor(make_snowflake(2), 325, -40),
    '</g>',
    '<!-- Decoration balls -->',
    string.format('<g stroke-width="%d">', 1),
    decor(make_decor_ball(colors.blue), 0, -40),
    decor(make_decor_ball(colors.purple), 75, -35),
    decor(make_decor_ball(colors.red), 150, -40),
    decor(make_decor_ball(colors.orange), 225, -40),
    decor(make_decor_ball(colors.yellow), 300, -35),
    '</g>',
  }

  local indent = string.rep(' ', 4)
  for i = 1, #decor_lines do
    table.insert(lines, #lines - 1, indent .. decor_lines[i])
  end

  -- - Save
  local out_christmas = 'logo-3/logo-minimax_christmas.svg'
  vim.fn.writefile(lines, out_christmas)
  make_social_png(out_christmas)
end

-- 'lang.nvim' ================================================================
local with_azure_lang_prefix = function(suffix_lines)
  local prefix_lines = {
    '<!-- L --> ' .. font.l,
    '<!-- A --> ' .. font.a,
    '<!-- N --> ' .. font.n,
    '<!-- G --> ' .. font.g,
    '<!-- . --> ' .. font['.'],
  }
  return with_azure_prefix(prefix_lines, suffix_lines)
end

_G.logo_lang_nvim = function()
  -- Construct svg content
  local suffix_lines = {
    '<!-- N --> ' .. set_stroke(font.n_1, colors.cyan) .. ' ' .. set_stroke(font.n_2, colors.green),
    '<!-- V --> ' .. font.v,
    '<!-- I --> ' .. font.i,
    '<!-- M --> ' .. font.m,
  }
  local lines = with_azure_lang_prefix(suffix_lines)

  -- Save
  local out = 'logo-3/logo-lang-nvim.svg'
  vim.fn.writefile(lines, out)
  make_social_png(out)
end

_G.logo_lang_module = function(name)
  -- Construct svg content
  local suffix_lines = {}
  for _, l in ipairs(vim.split(name, '')) do
    table.insert(suffix_lines, string.format('<!-- %s --> %s', l:upper(), font[l]))
  end
  local lines = with_azure_lang_prefix(suffix_lines)

  -- Save
  local out = 'logo-3/logo-lang-module-' .. name .. '.svg'
  vim.fn.writefile(lines, out)
  make_social_png(out)
end
