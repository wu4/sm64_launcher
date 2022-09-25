local scalefactor = love.graphics.getWidth() / 1920
print(scalefactor)

local function scaled(n)
  return math.ceil(n * scalefactor)
end

local grid_size = scaled(32)

local smallfont = love.graphics.newFont(scaled(22))
local bigfont = love.graphics.newFont(scaled(44))

local function print_columns(cols, width, y)
  -- local origin_left = width > 800 and ((width / 2) - 400) or 0
  local origin_left = 0

  local fixed_proportion = 0
  local non_fixed_count = 0
  for _, v in ipairs(cols) do
    if v[2] ~= -1 then
      fixed_proportion = fixed_proportion + v[2]
    else
      non_fixed_count = non_fixed_count + 1
    end
  end
  local remaining = width - fixed_proportion
  local non_fixed_width = remaining / non_fixed_count

  local cur_x = origin_left
  for x, v in ipairs(cols) do
    local w = v[2] == -1 and non_fixed_width or v[2]
    love.graphics.printf(v[1], cur_x, y, w, 'left')
    cur_x = cur_x + w
  end
end

local function draw_check(check, x, y, r,g,b, circle)
  if check then
    love.graphics.setColor(r,g,b)
  else
    love.graphics.setColor(0.5, 0.5, 0.5)
  end
  if circle then
    love.graphics.circle('fill', x + (grid_size / 2), y + (grid_size / 2), grid_size / 2 - 1)
  else
    love.graphics.rectangle('fill', x, y, grid_size - 1, grid_size - 1)
  end
end

---@param stage Stage
local function draw_stage_checks(stage)
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.printf(stage.shortname, 0, 0, scaled(100), 'right')
  for star_x, star in ipairs(stage) do
    draw_check(star, scaled(100) + (star_x * grid_size), 0, 1,1,0)
  end
  if stage.cannon ~= nil then
    draw_check(stage.cannon, scaled(100) + (8.5 * grid_size), 0, 1,0,0.5, true)
  end
end

local function draw_checks(prog)
  local sel_game = prog.games[prog.selected_id]
  if sel_game == nil then return end
  love.graphics.setFont(smallfont)
  love.graphics.push()
  love.graphics.translate(grid_size * 16, grid_size)
  draw_stage_checks(sel_game.stages[1])
  love.graphics.pop()
  for star_y = 2, 16 do
    love.graphics.push()
    love.graphics.translate(0, (star_y - 1) * grid_size)
    draw_stage_checks(sel_game.stages[star_y])
    love.graphics.pop()
  end
  for star_y = 1, 9 do
    love.graphics.push()
    love.graphics.translate(grid_size * 16, (star_y + 1) * grid_size)
    draw_stage_checks(sel_game.stages[star_y + 16])
    love.graphics.pop()
  end

  love.graphics.push()
  love.graphics.translate((grid_size * 18.5) + scaled(100), grid_size * 3)
  local caps_keys = sel_game.stages.caps_keys
  draw_check(caps_keys[1], 0, grid_size*4, 1,0,0)
  draw_check(caps_keys[2], 0, grid_size*3, 1,0,0)
  draw_check(caps_keys[3], 0, grid_size*5, 1,0,0)

  draw_check(caps_keys[4], 0, 0, 1,0.5,0)
  draw_check(caps_keys[3], 0, grid_size, 1,0.5,0)
  love.graphics.pop()
end

local function draw_boxed_text(text, x, y, w, h, highlight)
  local fh = love.graphics.getFont():getHeight()
  if highlight then
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(text, x, y + (h/2) - (fh/2), w, 'center')
  else
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', x, y, w, h)
    love.graphics.printf(text, x, y + (h/2) - (fh/2), w, 'center')
  end
end

return {
  draw_boxed_text = draw_boxed_text,
  draw_check = draw_check,
  draw_checks = draw_checks,
  draw_stage_checks = draw_stage_checks,
  print_columns = print_columns,
  smallfont = smallfont,
  bigfont = bigfont,
  scaled = scaled
}