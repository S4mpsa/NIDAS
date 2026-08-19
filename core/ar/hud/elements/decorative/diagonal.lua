local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param size Coordinate2D Width and heigth
---@param colour ColourHex
---@param alpha? float Alpha value between 0.0 and 1.0
---@param sides? table {-1,0,1, -1,0,1} Left/Right diagonal. -1 = Long edge on top. 1 = Long edge on bottom.
local function diagonal(position, size, colour, alpha, sides)
    local Element
    local function init(window)
        local quad = window.glasses.addQuad()
        local x, y = window.position.x, window.position.y
        local w, h = Element.size.x, Element.size.y
        quad.setColor(numUtils.toRGB(Element.data.colour))
        quad.setAlpha(Element.data.alpha)
        if Element.data.sides[1] ~= 0 then
            if Element.data.sides[1] == 1 then
                quad.setVertex(1, x + Element.position.x + h, y + Element.position.y)
                quad.setVertex(2, x + Element.position.x, y + Element.position.y + h)
            else
                quad.setVertex(1, x + Element.position.x, y + Element.position.y)
                quad.setVertex(2, x + Element.position.x + h, y + Element.position.y + h)
            end
        else
            quad.setVertex(1, x + Element.position.x, y + Element.position.y)
            quad.setVertex(2, x + Element.position.x, y + Element.position.y + h)
        end

        if Element.data.sides[2] ~= 0 then
            if Element.data.sides[2] == 1 then
                quad.setVertex(3, x + Element.position.x + w, y + Element.position.y + h)
                quad.setVertex(4, x + Element.position.x + w - h, y + Element.position.y)
            else
                quad.setVertex(3, x + Element.position.x + w - h, y + Element.position.y + h)
                quad.setVertex(4, x + Element.position.x + w, y + Element.position.y)
            end
        else
            quad.setVertex(3, x + Element.position.x + w, y + Element.position.y + h)
            quad.setVertex(4, x + Element.position.x + w, y + Element.position.y)
        end

        Element.data.widgets["quad"] = quad
    end

    local function update(window)

    end

    local function move(window)
        
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
        data = {widgets = {}, colour = colour or 0, alpha = alpha or 1.0, glasses = nil, sides = sides or {0, 0}}
    }

    return Element
end

return diagonal