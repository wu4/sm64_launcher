---@type love.Joystick
local joy

function love.load()
  joy = love.joystick.getJoysticks()[1]
end

function love.update(dt)
end

---comment
---@param file string
---@return number
local function get_modified_date(file)
  local f = assert(io.popen("stat -c %Y " .. file))
  local last_modified = tonumber(f:read())
  if last_modified then
    return last_modified
  else
    return -1
  end
end

function love.draw()
  local a = joy:getAxis(1)
  love.graphics.print(tostring(a), 0, 0)
end