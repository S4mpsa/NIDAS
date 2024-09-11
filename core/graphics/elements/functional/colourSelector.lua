local component = require("component") local gpu = component.gpu
local event = require("event")
local numUtils = require("core.lib.numUtils")
local term = require("term")
local io = require("io")
local colours = require("core.lib.colours")

---@param position Coordinate2D
---@param colour number
local function colourSelector(position, colour)

    blink = blink or true
    local function draw(window, element)
        gpu.setForeground(element.data.colour)
        gpu.set(position.x, position.y, numUtils.numberToColourHex(element.data.colour))
    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        gpu.setActiveBuffer(0)
        gpu.setForeground(element.data.colour)
        gpu.setBackground(theme.background)
        gpu.fill(window.position.x + element.position.x - 1, window.position.y + element.position.y - 1, 8, 1, " ")
        term.setCursor(window.position.x + element.position.x - 1, window.position.y + element.position.y - 1)
        local input = io.read()
        element.data.colour = tonumber(input) or 0xFF0000
        refresh()
        return true
    end
    local function onClickRight(window, element, eventName, address, x, y, button, name)
        local colourOptions = {}

        for colourName, value in pairs(colours) do
            local function setColour()
                element.data.colour = value
            end
            table.insert(colourOptions, {name = colourName, func = setColour, colour = value})
        end

        contextMenu(window, colourOptions, x, y)
        return true
    end
    local element = {
        size = {x=8, y=1},
        position = position,
        onClick = onClick,
        onClickRight = onClickRight,
        draw = draw,
        data = {colour = colour}
    }

    return element
end

return colourSelector