local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param string string
local function text(position, string, font, colour, alpha)

    local function init(window, element)
        local text = window.glasses.addTextLabel()
        text.setPosition(window.position.x + element.position.x, window.position.y + element.position.y)
        text.setScale(1.0)
        text.setText(string)
        text.setColor(numUtils.toRGB(element.data.colour))
        text.setAlpha(element.data.alpha)
        element.data.widgets["text"] = text
    end

    local function update(window, element)

    end

    local function move(window, element)
        element.data.widgets["text"].setPosition(window.position.x + element.position.x, window.position.y + element.position.y)
    end

    local function remove(window, element)
        window.glasses.removeObject(element.data.widgets["text"].getID())
    end

    local element = {
        size = {x=0, y=0},
        position = position,
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {widgets = {}, font = font or 1.0, colour = colour or 0xFFFFFF, alpha = alpha or 1.0}
    }

    return element
end

return text