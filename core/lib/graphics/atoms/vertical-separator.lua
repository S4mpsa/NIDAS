local gpu = require('component').gpu

---@param pos Coordinates
---@param size Coordinates
---@param title string
local function verticalSeparator(pos, size, title)
    local borderColor = 0x555555
    local primaryColor = 0xADD8E6
    local accentColor = 0xDD00DD

    gpu.setForeground(borderColor)
    local top = ''
    for _ = 1, size.y do
        top = top .. '│'
    end
    gpu.set(1 + pos.x, pos.y, top, true)

    if title then
        gpu.setForeground(primaryColor)
        gpu.set(1 + pos.x, 2 + pos.y, ' ' .. title .. ' ', true)
    end

    gpu.setForeground(accentColor)
end

return verticalSeparator
