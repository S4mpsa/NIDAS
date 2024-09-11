local component = require("component")
local event = require("event")
local numUtils = require("core.lib.numUtils")

---Creates a context menu with buttons that trigger functions provided in funcTable
---
---Format: {["ButtonText"] = func}
---@param funcTable table
---@param pos Coordinate2D

local function contextMenu(funcTable, pos)

    local Element
    local choiceHeight = 10
    local function init(window, element)
        --We want to capture all clicks so the element is the entire screen
        Element.size = {x=window.size.x, y=window.size.y}
        local selectionBox = window.glasses.addRect()
        selectionBox.setPosition(Element.data.choicePosition.x, Element.data.choicePosition.y)

        selectionBox.setColor(numUtils.toRGB(theme.background))
        selectionBox.setAlpha(0.3)
        Element.data.widgets["selectionBox"] = selectionBox
        local i = 0
        for key, func in pairs(funcTable) do
            local text = window.glasses.addTextLabel()
            text.setPosition(Element.data.choicePosition.x + 1, Element.data.choicePosition.y + 1 + choiceHeight*i)
            text.setScale(1.0)
            text.setText(key)
            text.setColor(numUtils.toRGB(theme.primaryColour))
            Element.data.widgets["choice" .. tostring(i+1)] = text
            if i > 0 then
                local divisor = window.glasses.addRect()
                divisor.setPosition(Element.data.choicePosition.x, Element.data.choicePosition.y + choiceHeight*i - 1)
                divisor.setSize(1, 100)
                divisor.setColor(numUtils.toRGB(theme.background))
                divisor.setAlpha(0.3)
                Element.data.widgets["divisor"..tostring(i+1)] = divisor
            end
            i = i + 1
            Element.data.choices[i] = func
        end
        selectionBox.setSize(i*(choiceHeight), 100)

    end

    local function update(window, element, tick)
        return true
    end

    local function move(window, element)

    end

    local function onClick(window, element, eventName, address, x, y, button, name)
        if (y >= Element.data.choicePosition.y - 1 and y < Element.data.choicePosition.y + #Element.data.choices * choiceHeight)
        and (x >= Element.data.choicePosition.x and x < Element.data.choicePosition.x + 100) then
            choice = math.ceil((y - Element.data.choicePosition.y) / choiceHeight)
            Element.remove(window, element)
            window.remove()
            if Element.data.choices[choice] then
                Element.data.choices[choice]()
            end
            return true
        else
            Element.remove(window, element)
            window.remove()
            return true
        end
    end

    local function onClickRight(window, element, eventName, address, x, y, button, name)
        Element.remove(window, element)
        window.remove()
        return true
    end

    local function onDrag(window, element, eventName, address, x, y, button, name)
        return true
    end

    local function onDragRight(window, element, eventName, address, x, y, button, name)
        return true
    end

    local function remove(window, element)
        for key, widget in pairs(Element.data.widgets) do
            window.glasses.removeObject(widget.getID())
        end
    end

    Element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        onClick = onClick,
        onClickRight = onClickRight,
        onDrag = onDrag,
        onDragRight = onDragRight,
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {choices = {}, choicePosition = {x=pos.x, y=pos.y}, widgets = {}}
    }

    return Element
end

return contextMenu