local component = require("component") local gpu = component.gpu
local event = require("event")
local term = require("term"); local text = require("text")
local numUtils = require("core.lib.numUtils")
local io = require("io")
---@param position Coordinate2D
---@param str string
function textField(position, str, width)
    local function draw(window, element)
        gpu.setForeground(theme.primaryColour)
        gpu.fill(element.position.x, element.position.y, width, 1, " ")
        if #element.data.str >= 1 then
            gpu.set(element.position.x, element.position.y, string.sub(element.data.str, 1, width))
        else
            gpu.set(element.position.x, element.position.y, "_")
        end
    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        gpu.setActiveBuffer(0)
        gpu.setForeground(theme.primaryColour)
        gpu.setBackground(theme.background)
        gpu.fill(window.position.x + element.position.x - 1, window.position.y + element.position.y - 1, width, 1, " ")
        term.setCursor(window.position.x + element.position.x - 1, window.position.y + element.position.y - 1)
        element.data.str = io.read()
        element.size = {x=numUtils.clamp(#element.data.str, 1, width), y=1}
        refresh()
        return true
    end

    local element = {
        size = {x=#str, y=1},
        position = position,
        onClick = onClick,
        draw = draw,
        data = {str = str, width = width}
    }

    return element
end

return textField