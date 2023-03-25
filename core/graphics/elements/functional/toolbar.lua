local component = require("component") local gpu = component.gpu
local event = require("event")

function toolbar()
    blink = blink or true
    local function draw(window, element)
        local x, y = gpu.getResolution()
        element.size = {x = x, y = 2}
        element.data.tabs = windowManager.getTabs()
        element.data.activeTab = windowManager.getActiveTab()
        gpu.fill(1, 1, element.size.x, element.size.y, " ")

        local offset = 1
        gpu.setForeground(theme.borderColour)
        gpu.set(1, 1, string.rep("_", x))

        for i, tab in ipairs(element.data.tabs) do
            if tab == element.data.activeTab then
                gpu.setForeground(theme.accentColour)
            else
                gpu.setForeground(theme.primaryColour)
            end
            gpu.set(offset + 1, 2, tab)
            offset = offset + #tab + 3
            gpu.setForeground(theme.borderColour)
            gpu.set(offset - 1, 2, "│")
        end

        gpu.set(element.size.x - 8, 2, "│")
        gpu.setForeground(theme.accentColour)
        gpu.set(element.size.x - 6, 2, "Reboot")

        gpu.setForeground(theme.borderColour)
        gpu.set(element.size.x - 18, 2, "NIDAS " .. element.data.version)

        gpu.set(element.size.x - 28, 2, "VRAM: " .. tostring( math.floor(((gpu.totalMemory() - gpu.freeMemory()) / gpu.totalMemory()) * 100) ) .. "%" )
    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        local offset = 0
        local xMax, yMax = gpu.getResolution()
        for i, tab in ipairs(element.data.tabs) do
            if x > offset and x < offset + #tab + 3 and y == yMax then
                windowManager.switchToTab(tab)
                return true
            end
            offset = offset + #tab + 3
        end
        if x > element.size.x - 8 and y == yMax then
            require("shell").execute("reboot")
        end
        return true
    end

    local x, y = gpu.getResolution()

    local element = {
        size = {x=x, y=2},
        position =  {x=1, y=1},
        onClick = onClick,
        draw = draw,
        data = {tabs = {}, version = require("version")}
    }

    return element
end

return toolbar