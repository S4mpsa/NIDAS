local gpu = require('component').gpu

---@param list table
local function button(pos, title, list)
    ---@type Component
    local buttonComponent = {
        id = 'button',
        pos = pos,
        size = { y = #list + 1 },
        onRender = function(absolutePosition)
            gpu.setForeground(0xADD8E6)
            gpu.set(absolutePosition.x, absolutePosition.y, title)

            for index = 1, #list - 1 do
                gpu.set(
                    absolutePosition.x,
                    absolutePosition.y + index,
                    '├ ' .. list[index].name
                )
            end
            gpu.set(
                absolutePosition.x,
                absolutePosition.y + math.max(1, #list),
                '╰ ' .. (list[#list] or { name = 'None' }).name
            )
        end
    }

    return buttonComponent
end

return button
