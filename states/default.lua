local timeago = require 'lib.timeago'
local gfx = require 'gfx'

local default = {}

return {
  controls = '(a) start  (y) start new game  (x) delete game  (b) exit',

  init = function()

  end,

  callbacks = {
    ---@param prog Program
    a = function(prog)
      prog:launch(prog.games[prog.selected_id].player_name, prog.games[prog.selected_id].ip)
    end,
    ---@param prog Program
    b = function(prog)
      love.event.quit()
    end,
    ---@param prog Program
    x = function(prog)
      prog:change_state('prompt_delete')
    end,
    ---@param prog Program
    y = function(prog)
      prog:change_state('prompt_new')
    end,
    ---@param prog Program
    back = function(prog)
      os.execute('git pull origin')
      love.event.quit()
    end,
    ---@param prog Program
    up = function(prog)
      prog.selected_id = ((prog.selected_id - 2) % #prog.games) + 1
    end,
    ---@param prog Program
    down = function(prog)
      prog.selected_id = (prog.selected_id % #prog.games) + 1
    end,
  },

  ---@param prog Program
  draw = function(prog)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gfx.smallfont)
    local elem_width = love.graphics.getWidth() / 2
    gfx.print_columns({
      {'Checks', gfx.scaled(100)},
      {'Name', -1},
      {'Last played', -1},
    }, elem_width, gfx.scaled(16))
    love.graphics.setFont(gfx.bigfont)
    local y = gfx.scaled(60)
    for id, game in pairs(prog.games) do
      if prog.selected_id == id then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('fill', 0, y, elem_width, gfx.scaled(60))
        love.graphics.setColor(0, 0, 0)
      else
        love.graphics.setColor(0.5, 0.5, 0.5)
      end
      gfx.print_columns({
        {game.completion, gfx.scaled(100)},
        {game.player_name, -1},
        {timeago.format(game.last_played), -1},
      }, elem_width, y + gfx.scaled(4))
      y = y + gfx.scaled(60)
    end

    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, 0)
    gfx.draw_checks(prog)
    love.graphics.pop()
  end
}