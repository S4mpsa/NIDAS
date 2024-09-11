local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param position Coordinate2D
---@param size Coordinate2D
---@param func function
local function simpleButton(position, size, colour, alpha, func)

    local function init(window, element)
        local rectangle = window.glasses.addRect()
        rectangle.setPosition(window.position.x + element.position.x, window.position.y + element.position.y)
        rectangle.setSize(element.size.y, element.size.x)
        rectangle.setColor(numUtils.toRGB(element.data.colour))
        rectangle.setAlpha(element.data.alpha)
        element.data.widgets["simpleButton"] =  rectangle
    end

    local function update(window, element)

    end

    local function move(window, element)
        element.data.widgets["simpleButton"].setPosition(window.position.x + element.position.x, window.position.y + element.position.y)
    end

    local function onClick(window, element, eventName, address, x, y, button, name)
        element.data.func()
        return true
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

    local function remove(window, element)
        window.glasses.removeObject(element.data.widgets["simpleButton"].getID())
    end

    local element = {
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
        data = {widgets = {}, colour = colour or 0, alpha = alpha or 1.0, func = func}
    }

    return element
end

return simpleButton