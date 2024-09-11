local component = require("component")
local numUtils = require("core.lib.numUtils")

local function windowBorder()

    local function init(window, element)
        local background = window.glasses.addRect()
        background.setPosition(window.position.x, window.position.y)
        background.setSize(window.size.y, window.size.x)
        background.setColor(numUtils.toRGB(theme.background))
        background.setAlpha(0.6)
        element.data.widgets["background"] =  background

        local top = window.glasses.addRect()
        top.setPosition(window.position.x, window.position.y)
        top.setSize(5, window.size.x)
        top.setColor(numUtils.toRGB(theme.background))
        top.setAlpha(0.6)
        element.data.widgets["top"] =  top
    end

    local function update(window, element)

    end

    local function move(window, element)
        element.data.widgets["background"].setPosition(window.position.x, window.position.y)
        element.data.widgets["top"].setPosition(window.position.x, window.position.y)
    end

    local function remove(window, element)
        window.glasses.removeObject(element.data.widgets["background"].getID())
        window.glasses.removeObject(element.data.widgets["top"].getID())
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