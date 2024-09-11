local component = require("component") local gpu = component.gpu

---@param position Coordinate2D
---@param str string
---@param colour? number
local function singleLineText(position, str, colour)

    local function draw(window, element)
        gpu.setForeground(element.data.colour)
        gpu.set(position.x, position.y, element.data.str)
    end

    local element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        onClick = false,
        draw = draw,
        data = {colour = colour or theme.textColour, str = str},
    }
    return element
end

return singleLineText