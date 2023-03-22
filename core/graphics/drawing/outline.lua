local component = require("component") local gpu = component.gpu

local function outline(x, y, width)
    local top = "╭"
    local middle = "│"
    local bottom = "╰"
    for i = 1, width-2 do
        top = top .. "─"
        middle = middle .. " "
        bottom = bottom .. "─"
    end
    top = top .. "╮"
    middle = middle .. "│"
    bottom = bottom .. "╯"
    gpu.set(x, y, top)
    gpu.set(x, y+1, middle)
    gpu.set(x, y+2, bottom)
end

return outline