local config = require 'config'
local sm64parse = require 'parse'
local json = require 'lib.json'

---@class Game
---@field ip string
---@field last_played number
---@field folder_mdate number
---@field folder_name string
---@field full_path string
---@field player_name string
---@field completion number
---@field stages Stage[]

---@param dir string
---@return fun(): number, string
local function mdate_dir(dir)
  local f = assert(io.popen("/usr/bin/ls \"" .. dir .. "\" -ALclto --time-style=\"+%s\" --quoting-style=literal"))
  -- discard directory total
  local _ = f:read()

  return function()
    local line = f:read()
    if line ~= nil then
      local mdate, name = string.match(line, "..........%s+%S+%s+%S+%s+%S+%s+(%S+)%s+(.*)")
      return tonumber(mdate), name
    else
      f:close()
    end
  end
end

local function get_game_info(game)
  local ret = {last_played = -1}
  for mdate, name in mdate_dir(config.config_dir .. '/ap_save/' .. game) do
    if name == 'sm64_save_file.bin' then
      ret.last_played = mdate
      local f = assert(io.open(config.config_dir .. '/ap_save/' .. game .. '/sm64_save_file.bin', 'rb'))
      local savedata = f:read('*a')
      local completion, stages = sm64parse.get_check_count(savedata)
      ret.completion = completion
      ret.stages = stages
      f:close()
      break
    elseif name == 'data.json' then
    end
  end
  local f = io.open(config.config_dir .. '/ap_save/' .. game .. '/data.json', 'r')
  if f ~= nil then
    local info = json.decode(f:read("*a"))
    for k, v in pairs(info) do
      ret[k] = v
    end
  end

  return ret
end

---@return Game[]
local function get_games()
  local games = {}

  for mdate, name in mdate_dir(config.config_dir .. "/ap_save") do
    local game = get_game_info(name)
    game.folder_mdate = mdate
    game.folder_name = name
    game.full_path = config.config_dir .. '/ap_save/' .. name
    table.insert(games, game)
  end

  return games
end

local function file_exists(fname)
  local f = io.open(fname, "r")
  if f == nil then
    return false
  else
    f:close()
    return true
  end
end

return {
  file_exists = file_exists,
  get_games = get_games
}