local component = require("component") local gpu = component.gpu
local event = require("event")

local outline = require("core.graphics.drawing.outline")

---@param position Coordinate2D
---@param str string
---@param func function
---@param args table
---@param blink boolean
local function largeButton(position, str, func, args, blink)
    blink = blink or true
    local function draw(window, element)
        gpu.setForeground(theme.primaryColour)
        outline(position.x, position.y, element.size.x)
        gpu.setForeground(theme.textColour)
        gpu.set(position.x+1, position.y+1, str)
    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        func(table.unpack(args))
        if blink then
            local function flash()
                refresh(window, true)
            end
            gpu.setActiveBuffer(0)
            gpu.setForeground(theme.accentColour)
            outline(window.position.x + position.x - 1, window.position.y + position.y - 1, element.size.x)
            gpu.setForeground(theme.textColour)
            gpu.set(window.position.x + position.x, window.position.y + position.y, str)
            gpu.setForeground(theme.textColour)
            event.timer(0.3, flash, 1)
        end
        return true
    end

    local element = {
        size = {x=#str+2, y=3},
        position = position,
        onClick = onClick,
        draw = draw,
        data = {}
    }

    return element
end

return largeButton