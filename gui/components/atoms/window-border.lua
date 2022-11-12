local gpu = require('component').gpu

---@param pos Coordinate2D
---@param size Coordinate2D
---@param title string
local function windowBorder(pos, size, title)
    local borderColor = 0x555555
    local primaryColor = 0xADD8E6
    local accentColor = 0xDD00DD

    gpu.setForeground(borderColor)
    local top = '╭'
    local edges = '│'
    local bottom = '╰'
    for _ = 1, size.x - 2 do
        top = top .. '─'
        bottom = bottom .. '─'
    end
    for _ = 1, size.y - 3 do
        edges = edges .. '│'
    end
    top = top .. '╮'
    bottom = bottom .. '╯'
    gpu.set(1 + pos.x, 1 + pos.y, edges, true)
    gpu.set(size.x + pos.x, 1 + pos.y, edges, true)
    gpu.set(1 + pos.x, pos.y, top)
    gpu.set(1 + pos.x, size.y + pos.y - 1, bottom)

    gpu.setForeground(primaryColor)
    if title then
        gpu.set(3 + pos.x, pos.y, ' ' .. title .. ' ')
    end

    gpu.setForeground(accentColor)
end

return windowBorder
