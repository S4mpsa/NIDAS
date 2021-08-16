local screen = {}

function screen.toRGB(hex)
    local r = ((hex >> 16) & 0xFF) / 255.0
    local g = ((hex >> 8) & 0xFF) / 255.0
    local b = ((hex) & 0xFF) / 255.0
    return r, g, b
end

function screen.divideHex(hex, divisor)
    local r = ((hex >> 16) & 0xFF)
    local g = ((hex >> 8) & 0xFF)
    local b = ((hex) & 0xFF)
    local newHex = 0x000000
    newHex = newHex + ((math.ceil(divisor*r)) << 16)
    newHex = newHex + ((math.ceil(divisor*g)) << 8)
    newHex = newHex + (divisor*b)
    return newHex
end
-- Small = 1, Normal = 2, Large = 3, Auto = 4x to 10x (Even)
function screen.size(resolution, scale)
    scale = scale or 3
    return {resolution[1] / scale, resolution[2] / scale}
end

return screen
