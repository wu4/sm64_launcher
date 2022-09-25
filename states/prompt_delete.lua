local will_delete = false
local gfx = require 'gfx'

return {
  controls = '(a) confirm  (b) cancel',

  ---@param prog Program
  init = function(prog)
    will_delete = false
  end,

  callbacks = {
    ---@param prog Program
    a = function(prog)
      if will_delete then
        os.execute('rm -r "' .. prog.games[prog.selected_id].full_path .. '"')
        table.remove(prog.games, prog.selected_id)
        prog.selected_id = math.min(prog.selected_id, #prog.games)
      end
      prog:change_state('default')
    end,
    ---@param prog Program
    b = function(prog)
      prog:change_state('default')
    end,
    x = function()
    end,
    y = function()
    end,
    left = function(prog)
      will_delete = not will_delete
    end,
    right = function(prog)
      will_delete = not will_delete
    end,
  },

  ---@param prog Program
  draw = function(prog)
    love.graphics.setColor(1,1,1)
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.setFont(gfx.bigfont)
    love.graphics.printf('Are you sure you want to delete this game?', -300, -100, 600, 'center')
    love.graphics.setFont(gfx.smallfont)
    local h = gfx.smallfont:getHeight()
    gfx.draw_boxed_text('No', -105, 40, 70, 40, not will_delete)
    gfx.draw_boxed_text('Yes', 35, 40, 70, 40, will_delete)
    love.graphics.pop()
  end

}