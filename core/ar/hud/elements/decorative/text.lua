local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param string string
local function text(position, string, font, colour, alpha)
    local Element

    local function init(window)
        local t = window.glasses.addTextLabel()
        t.setPosition(window.position.x + Element.position.x, window.position.y + Element.position.y)
        t.setScale(1.0)
        t.setText(string)
        t.setColor(numUtils.toRGB(Element.data.colour))
        t.setAlpha(Element.data.alpha)
        Element.data.widgets["text"] = t
    end

    local function update(window)

    end

    local function move(window)
        Element.data.widgets["text"].setPosition(window.position.x + Element.position.x, window.position.y + Element.position.y)
    end

    local function remove(window)
        window.glasses.removeObject(Element.data.widgets["text"].getID())
    end

    Element = {
        size = {x=0, y=0},
        position = position,
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {widgets = {}, font = font or 1.0, colour = colour or 0xFFFFFF, alpha = alpha or 1.0}
    }

    return Element
end

return text