local component = require("component")
if not component.isAvailable("geolyzer") then
  io.stderr:write("This program requires a Geolyzer to run.\n")
  return
end
if not component.isAvailable("hologram") then
  io.stderr:write("This program requires a Hologram Projector to run.\n")
  return
end

local sx, sz = 48, 48
local ox, oz = -24, -24
local starty, stopy = -5

local function validateY(value, min, max, default)
  value = tonumber(value) or default
  if value < min or value > max then
    io.stderr:write("invalid y coordinate, must be in [" .. min .. ", " .. max .. "]\n")
    os.exit(1)
  end
  return value
end

do
  local args = {...}
  starty = validateY(args[1], -32, 31, starty)
  stopy = validateY(args[2], starty, starty + 32, math.min(starty + 32, 31))
end

component.hologram.clear()
component.hologram.setScale(3)
component.hologram.setPaletteColor(1, 0x444444)
component.hologram.setPaletteColor(2, 0xAA00AA)
component.hologram.setPaletteColor(3, 0x22BB22)
for x=ox,sx+ox do
  for z=oz,sz+oz do
    local hx, hz = 1 + x - ox, 1 + z - oz
    local column = component.geolyzer.scan(x, z, false)
    for y=1,1+stopy-starty do
      local color = 0
      if column then
        local hardness = column[y + starty + 32]
        if hardness == 0 or not hardness then
          color = 0
        elseif hardness < 3 then
          color = 2
        elseif hardness < 100 then
          color = 1
        else
          color = 3
        end
      end
      if component.hologram.maxDepth() > 1 then
        component.hologram.set(hx, y, hz, color)
      else
        component.hologram.set(hx, y, hz, math.min(color, 1))
      end
    end
    os.sleep(0)
  end
end