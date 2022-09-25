local sm64exdir = os.getenv("HOME") .. "/.games/sm64ex/build/us_pc"
local sm64exconfig = os.getenv("HOME") .. "/.local/share/sm64ex"

local json = require 'lib.json'

---@class Config
---@field binary_dir string
---@field config_dir string
---@field default_name string

local f = assert(io.open(os.getenv("HOME") .. "/.local/share/sm64ex/sm64_launcher.json", 'r'))

---@type Config
local contents = json.decode(f:read("*a"))

return contents