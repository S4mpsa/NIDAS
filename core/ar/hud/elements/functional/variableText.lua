local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param stringSource function
---@param font? number
---@param colour? number
---@param alpha? any
---@param rate? integer
---@param align? integer -1/0/1. Align the text to left/center/right of the position.
local function variableText(position, stringSource, font, colour, alpha, rate, align)

    local Element
    local function init(window)
        Element.window = window
        local text = window.glasses.addTextLabel()
        text.setPosition(window.position.x + Element.position.x, window.position.y + Element.position.y)
        text.setScale(font)
        text.setText(stringSource())
        text.setColor(numUtils.toRGB(Element.data.colour))
        text.setAlpha(Element.data.alpha)
        Element.data.widgets["text"] = text
    end

    local function update(tick)
        if tick % rate == 0 then
            local str = Element.data.stringSource()
            Element.data.widgets["text"].setText(str)
            Element.data.text = str
            if align == 1 then
                Element.data.widgets["text"].setPosition(Element.window.position.x + Element.position.x - 11 - (4.5*#str), Element.window.position.y + position.y)
            elseif align == 0 then
                Element.data.widgets["text"].setPosition(Element.window.position.x + Element.position.x - ((2.25*#str)), Element.window.position.y + position.y)
            end
        end
    end

    ---@param position Coordinate2D
    local function move(position)
        Element.position = position
        Element.data.widgets["text"].setPosition(Element.window.position.x + position.x, Element.window.position.y + position.y)
    end

    local function remove(window)
        window.glasses.removeObject(Element.data.widgets["text"].getID())
    end

    Element = {
        window = nil,
        size = {x=0, y=0},
        position = position,
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {widgets = {}, font = font or 1.0, colour = colour or 0xFFFFFF, alpha = alpha or 1.0,
                rate = rate or 1, text = "", align = align or -1, stringSource = stringSource}
    }

    return Element
end

return variableText