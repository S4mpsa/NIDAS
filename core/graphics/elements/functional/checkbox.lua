local component = require("component") local gpu = component.gpu
local event = require("event")
local term = require("term"); local text = require("text")
local numUtils = require("core.lib.numUtils")
local io = require("io")
---@param position Coordinate2D
---@param value boolean
local function textField(position, value)
    local function draw(window, element)
        gpu.setForeground(theme.borderColour)
        gpu.fill(element.position.x, element.position.y, 3, 1, " ")
        gpu.set(element.position.x, element.position.y, "< >")
        if element.data.value == true then
            gpu.setForeground(0x00FF00)
            gpu.set(element.position.x + 1, element.position.y, "━")
        elseif element.data.value == false then
            gpu.set(element.position.x + 1, element.position.y, " ")
        end
    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        element.data.value = not element.data.value
        refresh()
        return true
    end

    local element = {
        size = {x=4, y=1},
        position = position,
        onClick = onClick,
        draw = draw,
        data = {value = value}
    }

    return element
end

return textField