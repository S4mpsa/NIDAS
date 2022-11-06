local gpu = require('component').gpu

---@param pos Coordinates
---@param size Coordinates
---@param title string
local function horizontalSeparator(pos, size, title)
    local borderColor = 0x555555
    local primaryColor = 0xADD8E6
    local accentColor = 0xDD00DD

    gpu.setForeground(borderColor)
    local top = ''
    for _ = 1, size.x do
        top = top .. '▂'
    end
    gpu.set(1 + pos.x, pos.y, top)

    if title then
        gpu.setForeground(primaryColor)
        gpu.set(3 + pos.x,pos.y, ' ' .. title .. ' ')
    end

    gpu.setForeground(accentColor)
end

return horizontalSeparator
