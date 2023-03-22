local component = require("component"); local event = require("event")
local gpu = component.gpu

local elements = require("core.graphics.elements.element")

---@param window Window
---@param options table
---@param x number
---@param y number
function contextMenu(window, options, x, y)

    if windowManager then
        windowManager.pause()
    end

    local longestOption = 4
    for i, option in ipairs(options) do
        if #option.name > longestOption then
            longestOption = #option.name
        end
    end
    local contextWindow = windowManager.create("Dropdown Menu", {x=longestOption + 2, y=#options + 2}, {x=x, y=y}) --! Make the menu respect edges of the screen
    for i, option in ipairs(options) do
        contextWindow.addElement(elements.singleLineText({x = 2, y = 1 + i}, option.name, option.colour or theme.textColour))
    end
    contextWindow.addElement(elements.border(theme.borderColour))
    refresh()

    local function onClick(eventName, address, clickX, clickY, button, name)
        if (clickY > y and clickY < y + #options + 1) and (clickX > x and clickX < x + longestOption + 2 - 1) and button == 0 then
            local selection = clickY - y
            options[selection].func()
        end
        windowManager.detach(contextWindow)
        contextWindow.remove()
        event.ignore("touch", onClick)
        if windowManager then
            windowManager.resume()
        end
        refresh()
    end

    event.listen("touch", onClick)
end

return contextMenu