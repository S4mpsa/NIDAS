local screen = {}

function screen.toRGB(hex)
    local r = ((hex >> 16) & 0xFF) / 255.0
    local g = ((hex >> 8) & 0xFF) / 255.0
    local b = ((hex) & 0xFF) / 255.0
    return r, g, b
end

-- Small = 1, Normal = 2, Large = 3, Auto = 4x to 10x (Even)
function screen.size(resolution, scale)
    scale = scale or 3
    return {resolution[1] / scale, resolution[2] / scale}
end

return screen
