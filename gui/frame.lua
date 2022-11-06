local horizontalSeparator = require('core.lib.graphics.atoms.horizontal-separator')
local verticalSeparator = require('core.lib.graphics.atoms.vertical-separator')
local gpu = require('component').gpu

local function label(title) return {
        id = title,
        pos = { x = 1 },
        size = { x = -2 },
        onRender = function(pos, size)
            horizontalSeparator(pos, size, title)
        end
    }
end

local separator = {
    id = 'separator',
    pos = { y = 1 },
    size = { y = -2 },
    onRender = verticalSeparator,
}

---@return Component
local function footer(isDisplayingTheHand)
    return {
        id = 'footer',
        pos = { y = -3 },
        onRender = horizontalSeparator,
        ---@type Component[]
        children = isDisplayingTheHand
            and { {} }
            or { {
                id = 'return-button',
                pos = { x = 1, y = 1 },
                size = { x = 12 },
                onRender = function(pos)
                    gpu.set(pos.x, pos.y, '< < < Return')
                end,
                onClick = function()
                    print('return')
                    coroutine.yield('return')
                end
            } }
    }
end

---The frame present on every screen
---@param title string
---@param centerComponent Component
---@return Component
local function outerFrame(
    title,
    centerComponent
)
    local isDisplayingTheHand = title == 'The Hand of NIDAS'

    ---@type Component
    local component = {
        id = 'outer-frame',
        pos = { x = 0, y = 2 },
        size = { x = 160, y = 50 },
        children = {
            label(title),
            {
                id = 'center-component',
                pos = { x = 41, y = 2 },
                size = { y = -5 },
                children = {
                    separator,
                    centerComponent or {}
                },
            },
            footer(isDisplayingTheHand)
        }
    }

    return component
end

return outerFrame
