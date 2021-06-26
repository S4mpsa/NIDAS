local colors = {
    red = 0xFF0000,
    lime = 0x00FF00,
    blue = 0x0000FF,
    magenta = 0xFF00FF,
    yellow = 0xFFFF00,
    cyan = 0x00FFFF,
    greenYellow = 0xADFF2F,
    green = 0x008000,
    darkOliveGreen = 0x556B2F,
    indigo = 0x4B0082,
    purple = 0x800080,
    deepSkyBlue = 0x00BFFF,
    dodgerBlue = 0x1E90FF,
    steelBlue = 0x4682B4,
    darkSlateBlue = 0x483D8B,
    midnightBlue = 0x191970,
    navy = 0x000080,
    darkOrange = 0xFFA500,
    rosyBrown = 0xBC8F8F,
    goldenRod = 0xDAA520,
    chocolate = 0xD2691E,
    brown = 0xA52A2A,
    maroon = 0x800000,
    white = 0xFFFFFF,
    lightGray = 0xD3D3D3,
    darkGray = 0xA9A9A9,
    darkSlateGrey = 0x2F4F4F,
    notBlack = 0x181828,
    black = 0x000000
}

---[[
local newColors = {
    background = colors.black,
    machineBackground = colors.black,
    progressBackground = colors.indigo,
    barColor = colors.deepSkyBlue,
    labelColor = colors.goldenRod,
    idleColor = colors.lime,
    workingColor = colors.deepSkyBlue,
    offColor = colors.brown,
    errorColor = colors.red,
    positiveEUColor = colors.lime,
    negativeEUColor = colors.red,
    timeColor = colors.purple,
    textColor = colors.steelBlue,
    hudColor = colors.darkSlateGrey,
    mainColor = colors.goldenRod,
    accentA = colors.cyan,
    accentB = colors.blue
}

for name, color in pairs(newColors) do
    colors[name] = color
end

--[[

local RGB = {}

for name, value in pairs(colors) do
    local function hexToRGB(hexcode)
        local r = ((hexcode >> 16) & 0xFF) / 255.0
        local g = ((hexcode >> 8) & 0xFF) / 255.0
        local b = ((hexcode) & 0xFF) / 255.0
        return r, g, b
    end
    RGB[name] = hexToRGB(value)
end

colors.RGB = RGB

--]]
setmetatable(
    colors,
    {
        __index = function(self, color)
            return self[color] or 0, 0, 0
        end
    }
)

--]]
return colors
