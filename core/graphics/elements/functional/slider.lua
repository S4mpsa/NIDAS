local component = require("component") local gpu = component.gpu
local event = require("event")
local term = require("term"); local text = require("text")
local numUtils = require("core.lib.numUtils")
---@param position Coordinate2D
---@param steps table
---@param defaultIndex number
---@param width number
local function slider(position, steps, defaultIndex, width)

    local function compareLocations(stepOffsets, offset)
        for i, stepOffset in ipairs(stepOffsets) do
            if stepOffset >= offset then
                local left = stepOffset
                local right = stepOffsets[i+1] or 0
                if offset - left < right - offset then
                    return i
                else
                    return i + 1
                end
            end
        end
    end

    local function draw(window, element)
        local bar = "╞"
        for i = 1, width-2, 1 do bar = bar .. "═" end
        bar = bar .. "╡"
        gpu.setForeground(theme.borderColour)
        gpu.set(element.position.x, element.position.y + 1, bar)

        gpu.setForeground(theme.accentColour)
        gpu.set(element.position.x + element.data.stepLocations[element.data.index], element.position.y + 1, "⊚")

        gpu.fill(element.position.x, element.position.y, width, 1, " ")
        gpu.setForeground(theme.textColour)
        gpu.set(element.position.x + width/2 - #tostring(element.data.value)/2, element.position.y, tostring(element.data.value))

    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        local clickOffset = x - window.position.x - element.position.x + 1
        element.data.index = compareLocations(element.data.stepLocations, clickOffset)
        element.data.value = steps[element.data.index]
        refresh(window, true)
        return true
    end
    local function onClickRight(window, element, eventName, address, x, y, button, name)
        local stepOptions = {}

        for i, value in ipairs(steps) do
            local function setValue()
                element.data.value = value
                element.data.index = i
            end
            table.insert(stepOptions, {name = tostring(value), func = setValue})
        end

        contextMenu(window, stepOptions, x, y)
        return true
    end
    local function onDrag(window, element, eventName, address, x, y, button, name)
        local clickOffset = x - window.position.x - element.position.x
        element.data.index = compareLocations(element.data.stepLocations, clickOffset)
        element.data.value = steps[element.data.index]
        refresh(window, true)
        return true
    end

    local stepLocations = {1}
    local stepSize = (width - 2) / (#steps - 1)
    for i, step in ipairs(steps) do
        if i == #steps - 1 then
            table.insert(stepLocations, width-2)
        else
            table.insert(stepLocations, 1 + i * stepSize)
        end
    end

    local element = {
        size = {x=width, y=2},
        position = position,
        onClick = onClick,
        onClickRight = onClickRight,
        onDrag = onDrag,
        draw = draw,
        data = {value = steps[defaultIndex], index = defaultIndex, stepLocations = stepLocations}
    }

    return element
end

return slider