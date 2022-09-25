local will_create = false
local ip_text
local name_text
local selected_text

local gfx = require 'gfx'
local config = require 'config'
local utf8 = require 'utf8'

local textbox_mt = {}
textbox_mt.__index = textbox_mt
function textbox_mt:draw()
  love.graphics.setFont(gfx.smallfont)
  do
    local w = gfx.smallfont:getWidth(self.label)
    love.graphics.print(self.label, self.x - w - 10, self.y)
  end
  do
    local w = gfx.smallfont:getWidth(self.text)
    love.graphics.print(self.text, self.x, self.y)
    if selected_text == self then
      love.graphics.line(self.x + w, self.y, self.x + w, self.y + gfx.smallfont:getHeight())
    end
  end
end
function textbox_mt:textinput(t)
  self.text = self.text .. t
end
function textbox_mt:keypressed(key)
  if key == 'backspace' then
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(self.text, -1)

    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
        self.text = string.sub(self.text, 1, byteoffset - 1)
    end
  end
end

return {
  controls = '[tab] switch textbox  [enter] start  (b) cancel',

  ---@param prog Program
  init = function(prog)
    local gxmid = love.graphics.getWidth() / 2
    love.keyboard.setTextInput(true, gxmid - 200, 200, 400, 100)
    will_create = false
    ip_text = setmetatable({text = '', label = 'IP:Port', x = 0, y = 0}, textbox_mt)
    name_text = setmetatable({text = config.default_name or '', label = 'Player Name', x = 0, y = 40}, textbox_mt)
    selected_text = ip_text
  end,

  callbacks = {
    ---@param prog Program
    a = function(prog)
    end,
    ---@param prog Program
    b = function(prog)
      prog:change_state('default')
      love.keyboard.setTextInput(false)
    end,
    x = function()
    end,
    y = function()
    end,
    ---@param prog Program
    left = function(prog)
      will_create = not will_create
    end,
    ---@param prog Program
    right = function(prog)
      will_create = not will_create
    end,
    ---@param prog Program
    ---@param key string
    keypressed = function(prog, key)
      if key == 'tab' then
        if selected_text == ip_text then
          selected_text = name_text
        else
          selected_text = ip_text
        end
      elseif key == 'return' then
        prog:launch(name_text.text, ip_text.text)
        prog:change_state('default')
        love.keyboard.setTextInput(false)
      else
        selected_text:keypressed(key)
      end
    end,
    ---@param prog Program
    ---@param t string
    textinput = function(prog, t)
      selected_text:textinput(t)
    end
  },

  ---@param prog Program
  draw = function(prog)
    love.graphics.setColor(1,1,1)
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, 200)
    love.graphics.setFont(gfx.smallfont)
    ip_text:draw()
    name_text:draw()
    love.graphics.pop()
  end

}