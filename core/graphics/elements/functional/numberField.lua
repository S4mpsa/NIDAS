local component = require("component") local gpu = component.gpu
local event = require("event")
local term = require("term"); local text = require("text")
local numUtils = require("core.lib.numUtils")
local io = require("io")
---@param position Coordinate2D
---@param num number
---@param width number
local function numberField(position, num, width)
    local function draw(window, element)
        gpu.setForeground(theme.primaryColour)
        gpu.fill(element.position.x, element.position.y, width, 1, " ")
        if element.data.num ~= nil then
            if #tostring(element.data.num) >= 1 then
                gpu.set(element.position.x, element.position.y, string.sub(tostring(element.data.num), 1, width))
            else
                gpu.set(element.position.x, element.position.y, "_")
            end
        else
            gpu.setForeground(0xBB0000)
            gpu.set(element.position.x, element.position.y, "Invalid")
        end
    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        gpu.setActiveBuffer(0)
        gpu.setForeground(theme.primaryColour)
        gpu.setBackground(theme.background)
        gpu.fill(window.position.x + element.position.x - 1, window.position.y + element.position.y - 1, width, 1, " ")
        term.setCursor(window.position.x + element.position.x - 1, window.position.y + element.position.y - 1)
        local input = io.read()
        element.data.num = tonumber(input)
        if element.data.num ~= nil then
            element.size = {x=numUtils.clamp(#tostring(element.data.num), 1, width), y=1}
        else
            element.size = {x=width, y=1}
        end
        refresh()
        return true
    end

    local element = {
        size = {x=#tostring(num), y=1},
        position = position,
        onClick = onClick,
        draw = draw,
        data = {num = tonumber(num), width = width}
    }

    return element
end

return numberField