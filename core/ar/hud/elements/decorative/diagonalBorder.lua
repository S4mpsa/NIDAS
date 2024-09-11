local component = require("component")
local numUtils = require("core.lib.numUtils")

local barWidth = 3

local function windowBorder()

    local function init(window, element)
        local x, y = window.position.x, window.position.y

        local top = window.glasses.addQuad()
        top.setColor(numUtils.toRGB(theme.borderColour))
        top.setVertex(4, x, y)
        top.setVertex(3, x + window.size.x - barWidth, y)
        top.setVertex(2, x + window.size.x, y + barWidth)
        top.setVertex(1, x, y + barWidth)
        top.setAlpha(0.8)
        element.data.widgets["top"] = top

        local left = window.glasses.addQuad()
        left.setColor(numUtils.toRGB(theme.borderColour))
        left.setVertex(4, x, y + barWidth)
        left.setVertex(3, x + barWidth , y + barWidth)
        left.setVertex(2, x + barWidth, y + window.size.y)
        left.setVertex(1, x, y + window.size.y - barWidth)
        left.setAlpha(0.8)
        element.data.widgets["left"] = left

        local backgroundRect = window.glasses.addRect()
        backgroundRect.setColor(numUtils.toRGB(theme.background))
        backgroundRect.setPosition(x + barWidth, y + barWidth)
        backgroundRect.setSize(window.size.y / 2, window.size.x - 5)
        backgroundRect.setAlpha(0.6)
        element.data.widgets["backgroundRect"] = backgroundRect

        local backgroundDiagonal = window.glasses.addQuad()
        backgroundDiagonal.setColor(numUtils.toRGB(theme.background))
        backgroundDiagonal.setVertex(4, x + barWidth, y + barWidth + window.size.y / 2)
        backgroundDiagonal.setVertex(3, x + window.size.x - 2, y + barWidth + window.size.y / 2)
        backgroundDiagonal.setVertex(2, x + window.size.x + barWidth - window.size.y / 2, y + window.size.y - 2)
        backgroundDiagonal.setVertex(1, x + barWidth, y + window.size.y - 2)
        backgroundDiagonal.setAlpha(0.6)
        element.data.widgets["backgroundDiagonal"] = backgroundDiagonal
    end

    local function update(window, element)

    end

    local function move(window, element)
        --element.data.widgets["background"].setPosition(window.position.x, window.position.y)
        --element.data.widgets["top"].setPosition(window.position.x, window.position.y)
    end

    local function remove(window, element)
        for key, widget in pairs(element.data.widgets) do
            window.glasses.removeObject(widget.getID())
        end
    end



    local element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {widgets = {}}
    }

    return element
end

return windowBorder