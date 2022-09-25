---@type love.Joystick
local joy

local md5 = require 'lib.md5'
local json = require 'lib.json'
local timeago = require 'lib.timeago'
local ffi     = require 'ffi'
local sm64parse = require 'parse'
local dir = require 'dir'

local config = require 'config'

local function launch(name, ip)
  -- joy:release()
  love.window.close()

  local savepath = config.config_dir .. "/ap_save/" .. md5.sumhexa(ip .. name)
  os.execute("mkdir -p '" .. savepath .. "'")

  local datafile = savepath .. "/data.json"
  if not dir.file_exists(datafile) then
    local f = assert(io.open(datafile, "w"))
    f:write(json.encode({ip = ip, player_name = name}))
    f:close()
  end

  local configfile = savepath .. "/sm64config.txt"
  if not dir.file_exists(configfile) then
    os.execute("ln -s '" .. config.config_dir .. "/sm64config.txt' '" .. configfile .. "'")
  end

  os.execute(table.concat{
    'cd "', config.binary_dir,
    '" && ./sm64.us.f3dex2e ',
    '--sm64ap_name "', name, '" ',
    '--sm64ap_ip "', ip, '" ',
    '--savepath "', savepath, '"'
  })

  love.event.quit()
end

local function parse_url(url)
  local ip, name = string.match(url, "^sm64://(.*)/(.*)")
  if ip == nil or name == nil then
    
  else
    launch(name, ip)
  end
end

---@type Game[]
local games
local selected_id = 1

local smallfont = love.graphics.newFont(22)
local bigfont = love.graphics.newFont(44)
function love.load(...)
  love.window.setMode(0, 0, {fullscreen = true, fullscreentype = 'exclusive', borderless=true})
  local a = ...
  if a[1] ~= nil then
    parse_url(a[1])
  else
    joy = love.joystick.getJoysticks()[1]
    games = dir.get_games()
    for k, v in pairs(games) do
      print('table '..k)
      for kk, vv in pairs(v) do
        print(kk, vv)
      end
    end
  end
end

local pressed = {
  a = false,
  b = false,
  up = false,
  down = false
}
function love.update(dt)
  if love.keyboard.isDown('q') then love.event.quit() end
  local joy_y = joy:getAxis(2)
  if joy_y > 0.3 or joy:isGamepadDown('dpdown') then
    if not pressed.down then
      selected_id = (selected_id % #games) + 1
    end
    pressed.down = true
  else
    pressed.down = false
  end
  if joy_y < -0.3 or joy:isGamepadDown('dpup') then
    if not pressed.up then
      selected_id = ((selected_id - 2) % #games) + 1
    end
    pressed.up = true
  else
    pressed.up = false
  end
  if joy:isGamepadDown('a') then
    launch(games[selected_id].player_name, games[selected_id].ip)
  end
end

--[[
---comment
---@param file string
---@return number
local function get_modified_time(file)
  local f = assert(io.popen("stat -c %Y '" .. file .. "'"))
  local last_modified = tonumber(f:read("%l"))
  if last_modified then
    return last_modified
  else
    return -1
  end
end
--]]

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
    love.graphics.circle('fill', x + 16, y + 16, 15)
  else
    love.graphics.rectangle('fill', x, y, 31, 31)
  end
end

---@param stage Stage
local function draw_stage_checks(stage)
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.printf(stage.shortname, 0, 0, 100, 'right')
  for star_x, star in ipairs(stage) do
    draw_check(star, 100 + (star_x * 32), 0, 1,1,0)
  end
  if stage.cannon ~= nil then
    draw_check(stage.cannon, 100 + (8.5 * 32), 0, 1,0,0.5, true)
  end
end

local function draw_checks()
  local sel_game = games[selected_id]
  love.graphics.setFont(smallfont)
  love.graphics.push()
  love.graphics.translate(512, 32)
  draw_stage_checks(sel_game.stages[1])
  love.graphics.pop()
  for star_y = 2, 16 do
    love.graphics.push()
    love.graphics.translate(0, (star_y - 1) * 32)
    draw_stage_checks(sel_game.stages[star_y])
    love.graphics.pop()
  end
  for star_y = 1, 9 do
    love.graphics.push()
    love.graphics.translate(512, (star_y + 1) * 32)
    draw_stage_checks(sel_game.stages[star_y + 16])
    love.graphics.pop()
  end

  love.graphics.push()
  love.graphics.translate(612+64+16, 96)
  local caps_keys = sel_game.stages.caps_keys
  draw_check(caps_keys[1], 0, 32*4, 1,0,0)
  draw_check(caps_keys[2], 0, 32*3, 1,0,0)
  draw_check(caps_keys[3], 0, 32*5, 1,0,0)

  draw_check(caps_keys[4], 0, 0, 1,0.5,0)
  draw_check(caps_keys[3], 0, 32, 1,0.5,0)
  love.graphics.pop()
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(smallfont)
  local elem_width = love.graphics.getWidth() / 2
  print_columns({
    {'Checks', 100},
    {'Name', -1},
    {'Last played', -1},
  }, elem_width, 16)
  love.graphics.setFont(bigfont)
  local y = 60
  for id, game in pairs(games) do
    if selected_id == id then
      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle('fill', 0, y, elem_width, 60)
      love.graphics.setColor(0, 0, 0)
    else
      love.graphics.setColor(0.5, 0.5, 0.5)
    end
    print_columns({
      {game.completion, 100},
      {game.player_name, -1},
      {timeago.format(game.last_played), -1},
    }, elem_width, y + 4)
    y = y + 60
  end

  love.graphics.push()
  love.graphics.translate(love.graphics.getWidth() / 2, 0)
  draw_checks()
  love.graphics.pop()
end