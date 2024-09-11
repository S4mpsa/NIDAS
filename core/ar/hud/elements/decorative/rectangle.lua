local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param size Coordinate2D
local function rectangle(position, size, colour, alpha)
    local Element
    local function init(window, element)
        local rect = window.glasses.addRect()
        rect.setPosition(window.position.x + element.position.x, window.position.y + element.position.y)
        rect.setSize(element.size.y, element.size.x)
        rect.setColor(numUtils.toRGB(element.data.colour))
        rect.setAlpha(element.data.alpha)
        Element.data.widgets["rectangle"] = rect
    end

    local function update(window, element)

    end

    local function move(window, element)
        Element.data.widgets["rectangle"].setPosition(window.position.x + element.position.x, window.position.y + element.position.y)
    end

    local function onClick(window, element, eventName, address, x, y, button, name)
        return true
    end

    local function onClickRight(window, element, eventName, address, x, y, button, name)
        return true
    end

    local function onDrag(window, element, eventName, address, x, y, button, name)
        return true
    end

    local function onDragRight(window, element, eventName, address, x, y, button, name)
        return true
    end

    local function remove(window, element)
        for key, widget in pairs(element.data.widgets) do
            window.glasses.removeObject(widget.getID())
        end
    end

    Element = {
        size = size,
        position = position,
        onClick = onClick,
        onClickRight = onClickRight,
        onDrag = onDrag,
        onDragRight = onDragRight,
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {widgets = {}, colour = colour or 0, alpha = alpha or 1.0, glasses = nil}
    }

    return Element
end

return rectangle