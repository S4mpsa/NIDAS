local horizontalSeparator = require('gui.components.atoms.horizontal-separator')
local verticalSeparator = require('gui.components.atoms.vertical-separator')
local gpu = require('component').gpu

local function label(title)
    ---@type Component
    local labelComponent = {
        id = title,
        pos = { x = 1 },
        size = { x = -2 },
        onRender = function(pos, size)
            horizontalSeparator(pos, size, title)
        end
    }
    return labelComponent
end

local separator = {
    id = 'separator',
    pos = { y = 1 },
    size = { y = -2 },
    onRender = verticalSeparator,
}

---@return Component
local function footer(canReturn)
    ---@type Component
    local footerComponent = {
        id = 'footer',
        pos = { y = -1 },
        onRender = horizontalSeparator,
        ---@type Component[]
        children = { {
            id = 'return-button',
            pos = { x = 1, y = 1 },
            size = { x = 12 },
            onRender = function(pos)
                if canReturn then
                    gpu.set(pos.x, pos.y, '< < < Return')
                else
                    gpu.set(pos.x, pos.y, '            ')
                end
            end,
            onClick = function()
                if canReturn then
                    coroutine.yield('back')
                end
            end
        } }
    }
    return footerComponent
end

---The frame present on every screen
---@param canReturn boolean
---@param centerComponent Component
---@param title string
---@return Component
local function outerFrame(canReturn, centerComponent, title)
    ---@type Component
    local rootComponent = {
        id = 'outer-frame',
        pos = { x = 0, y = 2 },
        size = { x = 160, y = 48 },
        children = {
            label(title),
            {
                id = 'center-component',
                pos = { x = 41, y = 2 },
                size = { y = -3 },
                children = {
                    separator,
                    {
                        pos = { x = 2 },
                        children = { centerComponent or {} },
                    }
                },
            },
            footer(canReturn)
        }
    }

    return rootComponent
end

return outerFrame
