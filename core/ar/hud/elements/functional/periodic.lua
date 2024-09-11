local component = require("component")
local numUtils = require("core.lib.numUtils")

---@param func function
---@param rate number
local function periodic(func, rate)

    local function init(window, element)
        element.data.rate = rate
    end

    local function update(window, element, tick)
        if tick % rate == 0 then
            element.data.func()
        end
    end

    local function move(window, element)

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

    local function remove(window, element)

    end

    local element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        onClick = onClick,
        onClickRight = onClickRight,
        onDrag = onDrag,
        onDragRight = onDragRight,
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {widgets = {}, func = func, rate = rate}
    }

    return element
end

return periodic