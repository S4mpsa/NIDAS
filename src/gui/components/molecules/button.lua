local gpu = require('component').gpu

local windowBorder = require('gui.components.atoms.window-border')

---@param text string
---@param callback function
local function button(pos, size, text, callback)
    ---@type Component
    local buttonComponent = {
        id = 'button',
        pos = pos,
        size = {
            x = math.max(size.x or 0, #text + 2),
            y = (math.max(size.y or 0, 3))
        },
        onClick = callback,
        onRender = function(absolutePosition, absoluteSize)
            windowBorder(absolutePosition, absoluteSize)
            gpu.set(absolutePosition.x + 3, absolutePosition.y + 1, text)
        end
    }

    return buttonComponent
end

return button
