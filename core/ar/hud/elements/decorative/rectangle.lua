local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param size Coordinate2D Width and heigth
---@param colour ColourHex
---@param alpha float Alpha value between 0.0 and 1.0
local function rectangle(position, size, colour, alpha)
    local Element
    local function init(window)
        local rect = window.glasses.addRect()
        rect.setPosition(window.position.x + Element.position.x, window.position.y + Element.position.y)
        rect.setSize(Element.size.y, Element.size.x)
        rect.setColor(numUtils.toRGB(Element.data.colour))
        rect.setAlpha(Element.data.alpha)
        Element.data.widgets["rectangle"] = rect
    end

    local function update(window, element)

    end

    local function move(window)
        Element.data.widgets["rectangle"].setPosition(window.position.x + Element.position.x, window.position.y + Element.position.y)
    end

    local function onClick(window, element, eventName, address, x, y, button, name)
        return false
    end

    local function onClickRight(window, element, eventName, address, x, y, button, name)
        return false
    end

    local function onDrag(window, element, eventName, address, x, y, button, name)
        return false
    end

    local function onDragRight(window, element, eventName, address, x, y, button, name)
        return false
    end

    local function remove(window)
        for key, widget in pairs(Element.data.widgets) do
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