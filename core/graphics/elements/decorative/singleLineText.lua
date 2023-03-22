local component = require("component") local gpu = component.gpu

---@param position Coordinate2D
---@param str string
---@param colour? number
function singleLineText(position, str, colour)
    
    local function draw(window, element)
        colour = element.data.colour
        gpu.setForeground(colour)
        gpu.set(position.x, position.y, str)
    end

    local element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        onClick = false,
        draw = draw,
        data = {colour = colour or theme.textColour},
    }
    return element
end

return singleLineText