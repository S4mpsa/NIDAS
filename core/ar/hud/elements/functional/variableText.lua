local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param stringSource function
---@param font? number
---@param colour? number
---@param alpha? any
---@param rate? integer
local function text(position, stringSource, font, colour, alpha, rate)

    local function init(window, element)
        local text = window.glasses.addTextLabel()
        text.setPosition(window.position.x + element.position.x, window.position.y + element.position.y)
        text.setScale(1.0)
        text.setText(stringSource())
        text.setColor(numUtils.toRGB(element.data.colour))
        text.setAlpha(element.data.alpha)
        element.data.widgets["text"] = text
    end

    local function update(window, element, tick)
        if tick % rate == 0 then
            element.data.widgets["text"].setText(stringSource())
        end
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
        data = {widgets = {}, font = font or 1.0, colour = colour or 0xFFFFFF, alpha = alpha or 1.0, rate = rate or 1}
    }

    return element
end

return text