local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param size Coordinate2D Width and heigth
---@param colour ColourHex
---@param alpha? float Alpha value between 0.0 and 1.0
---@param sides? table {-1,0,1, -1,0,1} Left/Right diagonal. -1 = Long edge on top. 1 = Long edge on bottom.
---@param percentageSource function Function that returns 0..1.0
local function progressBar(position, size, colour, alpha, sides, percentageSource)
    local Element
    local function init(window)
        Element.window = window
        local bar = hudElements.diagonal(position, size, colour, alpha, sides)
        bar.init(Element.window)
        Element.data.widgets["bar"] = bar.data.widgets["quad"]
    end

    local function update()
        local bar = Element.data.widgets["bar"]
        local x, y = Element.window.position.x, Element.window.position.y
        local w, h = Element.size.x, Element.size.y
        local percentage = Element.data.percentageSource()
        bar.setVertex(3, x + Element.position.x + math.ceil(w*percentage) + h, y + Element.position.y + h)
        bar.setVertex(4, x + Element.position.x + math.ceil(w*percentage), y + Element.position.y)
    end

    local function move()
        
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
        window = window,
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
        data = {widgets = {}, colour = colour or 0, alpha = alpha or 1.0, glasses = nil, sides = sides or {0, 0}, percentageSource = percentageSource}
    }

    return Element
end

return progressBar