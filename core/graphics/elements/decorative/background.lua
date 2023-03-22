local component = require("component") local gpu = component.gpu

---@param colour number
function background(colour)
    
    local function draw(window, element)
        gpu.setForeground(colour)
        gpu.fill(1, 1, window.size.x, window.size.y, "█")
    end

    local element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        onClick = false,
        draw = draw,
        data = {}
    }
    return element
end

return background