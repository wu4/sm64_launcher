love.window.setMode(0, 0, {fullscreen = true, fullscreentype = 'exclusive', borderless=true})
love.keyboard.setTextInput(false)

---@type love.Joystick
local joy

local md5 = require 'lib.md5'
local json = require 'lib.json'
local timeago = require 'lib.timeago'
local ffi     = require 'ffi'
local sm64parse = require 'parse'
local dir = require 'dir'
local gfx = require 'gfx'

local config = require 'config'

local states = {}
states.default = require 'states.default'
states.prompt_delete = require 'states.prompt_delete'
states.prompt_new = require 'states.prompt_new'

---@class Program
local prog = {
  cur_state = 'default',
  state = states.default,
  ---@type Game[]
  games = {},
  selected_id = 1
}

function prog:change_state(state)
  self.cur_state = state
  self.state = states[state]
  states[state].init(self)
end

function prog:launch(name, ip)
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
    prog:launch(name, ip)
  end
end

function love.load(...)
  local a = ...
  if a[1] ~= nil then
    parse_url(a[1])
  else
    joy = love.joystick.getJoysticks()[1]
    prog.games = dir.get_games()
  end
end

function love.keypressed(key)
  if prog.state.callbacks.keypressed then
    prog.state.callbacks.keypressed(prog, key)
  end
end

function love.textinput(key)
  if prog.state.callbacks.textinput then
    prog.state.callbacks.textinput(prog, key)
  end
end

local pressed = {
  a = false,
  b = false,
  y = false,
  x = false,
  up = false,
  down = false,
  left = false,
  right = false
}

function love.draw()
  if prog.cur_state ~= 'default' then
    states.default.draw(prog)
    love.graphics.setColor(0,0,0, 0.8)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  end
  prog.state.draw(prog)

  love.graphics.setColor(1,1,1, 0.5)
  love.graphics.setFont(gfx.smallfont)

  local w = gfx.smallfont:getWidth(prog.state.controls)
  love.graphics.print(prog.state.controls, love.graphics.getWidth() - w, love.graphics.getHeight() - gfx.smallfont:getHeight())
end

function love.update(dt)
  if love.keyboard.isDown('escape') then love.event.quit() end
  local joy_y = joy:getAxis(2)
  local joy_x = joy:getAxis(1)

  for _, v in ipairs{'a', 'b', 'x', 'y'} do
    if joy:isGamepadDown(v) then
      if not pressed[v] then
        prog.state.callbacks[v](prog)
      end
      pressed[v] = true
    else
      pressed[v] = false
    end
  end

  if joy:isGamepadDown('x') then
    if not pressed.x then
      while true do
        love.event.pump()
        love.graphics.clear(0,0,0)
        love.graphics.present()
        if joy:isGamepadDown('b') then
          pressed.b = true
          break
        end
      end
    end
    pressed.x = true
  else
    pressed.x = false
  end

  if joy_y > 0.3 or joy:isGamepadDown('dpdown') then
    if not pressed.down and prog.state.callbacks.down then
      prog.state.callbacks.down(prog)
    end
    pressed.down = true
  else
    pressed.down = false
  end
  if joy_y < -0.3 or joy:isGamepadDown('dpup') then
    if not pressed.up and prog.state.callbacks.up then
      prog.state.callbacks.up(prog)
    end
    pressed.up = true
  else
    pressed.up = false
  end
  if joy_x > 0.3 or joy:isGamepadDown('dpright') then
    if not pressed.right and prog.state.callbacks.right then
      prog.state.callbacks.right(prog)
    end
    pressed.right = true
  else
    pressed.right = false
  end
  if joy_x < -0.3 or joy:isGamepadDown('dpleft') then
    if not pressed.left and prog.state.callbacks.left then
      prog.state.callbacks.left(prog)
    end
    pressed.left = true
  else
    pressed.left = false
  end
end