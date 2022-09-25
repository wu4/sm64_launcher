---@class Stage
---@field cannon boolean | nil
---@field name string
---@field shortname string

---@param byte integer
---@param star_count integer
---@param previous_stage_has_cannon boolean
---@return integer, Stage
local function parse_stage(byte, star_count, previous_stage_has_cannon)
  -- local b = ffi.cast("byte", ffi.new("char", byte))
  local total_checks = 0
  local stars = {}
  for i=1, star_count do
    if bit.band(byte, bit.lshift(1, i - 1)) > 0 then
      stars[i] = true
      total_checks = total_checks + 1
    else
      stars[i] = false
    end
  end
  if previous_stage_has_cannon then
    stars.cannon = bit.band(byte, bit.lshift(1, 7)) > 0
    if stars.cannon then total_checks = total_checks + 1 end
  end
  return total_checks, stars
end

local stages = {
  {name = "Bob-Omb Battlefield",         shortname = "BOB",   stars = 7, cannon = true},
  {name = "Whomp's Fortress",            shortname = "WF",    stars = 7, cannon = true},
  {name = "Jolly Roger Bay",             shortname = "JRB",   stars = 7, cannon = true},
  {name = "Cool, Cool Mountain",         shortname = "CCM",   stars = 7, cannon = true},
  {name = "Big Boo's Haunt",             shortname = "BBH",   stars = 7, cannon = false},
  {name = "Hazy Maze Cave",              shortname = "HMC",   stars = 7, cannon = false},
  {name = "Lethal Lava Land",            shortname = "LLL",   stars = 7, cannon = false},
  {name = "Shifting Sand Land",          shortname = "SSL",   stars = 7, cannon = true},
  {name = "Dire, Dire Docks",            shortname = "DDD",   stars = 7, cannon = false},
  {name = "Snowman's Land",              shortname = "SL",    stars = 7, cannon = true},
  {name = "Wet-Dry World",               shortname = "WDW",   stars = 7, cannon = true},
  {name = "Tall, Tall Mountain",         shortname = "TTM",   stars = 7, cannon = true},
  {name = "Tiny-Huge Island",            shortname = "THI",   stars = 7, cannon = true},
  {name = "Tick Tock Clock",             shortname = "TTC",   stars = 7, cannon = false},
  {name = "Rainbow Ride",                shortname = "RR",    stars = 7, cannon = true},
  {name = "Bowser in the Dark World",    shortname = "BitDW", stars = 1, cannon = false},
  {name = "Bowser in the Fire Sea",      shortname = "BitFS", stars = 1, cannon = false},
  {name = "Bowser in the Sky",           shortname = "BitS",  stars = 1, cannon = false},
  {name = "The Princess's Secret Slide", shortname = "Slide", stars = 2, cannon = false},
  {name = "Cavern of the Metal Cap",     shortname = "MCR",   stars = 1, cannon = false},
  {name = "Tower of the Wing Cap",       shortname = "WCR",   stars = 1, cannon = false},
  {name = "Vanish Cap Under the Moat",   shortname = "VCR",   stars = 1, cannon = false},
  {name = "Wing Mario Over the Rainbow", shortname = "WMOtR", stars = 1, cannon = false},
  {name = "The Secret Aquarium",         shortname = "Aqua",  stars = 1, cannon = false},
}

---@param data string
---@return integer, Stage[]
local function get_check_count(data)
  local sum = 0
  local checks_total = {}
  do -- castle stars
    local checks, stars = parse_stage(string.byte(data, 9), 5, false)
    stars.name = "Castle"
    stars.shortname = "CSS"
    table.insert(checks_total, stars)
    sum = sum + checks
  end
  local start_byte = 13
  for i, stage in ipairs(stages) do
    local has_cannon = false
    -- cannon data is stored in the stage after it
    if i > 1 then
      has_cannon = stages[i-1].cannon
    end
    local checks_count, stage_checks = parse_stage(string.byte(data, start_byte), stage.stars, has_cannon)
    stage_checks.name = stage.name
    stage_checks.shortname = stage.shortname
    if i > 1 then
      checks_total[i].cannon = stage_checks.cannon
      stage_checks.cannon = nil
    end
    table.insert(checks_total, stage_checks)
    sum = sum + checks_count
    start_byte = start_byte + 1
  end

  do
    -- keys and caps
    local byte = string.byte(data, 12)
    checks_total.caps_keys = {}
    -- wing, metal, vanish, basement, upper
    for b=1, 5 do
      local found = bit.band(byte, bit.lshift(1, b)) > 0
      table.insert(checks_total.caps_keys, found)
      if found then sum = sum + 1 end
    end
  end
  
  return sum, checks_total
end

return {
  get_check_count = get_check_count
}