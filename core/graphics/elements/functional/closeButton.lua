local component = require("component") local gpu = component.gpu

local function closeButton()

    local initialized = false

    local function draw(window, element)
        if not initialized then
            element.position = {x = window.size.x - 1, y = 1}
            initialized = true
        end
        colour = element.data.colour
        gpu.setForeground(0xBB0000)
        gpu.set(window.size.x-1, 1, "X")
    end

    local function onClick(window, element, eventName, address, x, y, button, name)
        windowManager.detach(window)
        window.remove()
        refresh()
    end

    local element = {
        size = {x=1, y=1},
        position = {x=0, y=0},
        onClick = onClick,
        draw = draw,
        data = {},
    }
    return element
end

return closeButton