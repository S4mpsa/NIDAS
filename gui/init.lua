local frame = require('gui.graphics.components.molucules.frame')
local engine = require('gui.graphics.core.engine')

local wrap = require('lib.lua-extensions.wrap')

local main = wrap(function(centerComponent, navigationStack)
    while true do
        local page = frame(
            #navigationStack > 1,
            centerComponent,
            navigationStack[#navigationStack]
        )
        engine.render(page)
        engine.registerEvents(page)

        centerComponent = coroutine.yield()
    end
end)

local gui = {}

---@param modules Module[]
---@param processor EventProcessor
---@return function
function gui.new(modules, processor)
    local navigationStack = { modules[1].name }

    local wrappedCoroutines = {}
    for _, module in ipairs(modules) do
        wrappedCoroutines[module.name] = wrap(module.core)
    end

    return function(payload)
        local moduleName = payload.name
        if moduleName == navigationStack[#navigationStack]
            and wrappedCoroutines[moduleName]
        then
            local result = main(
                wrappedCoroutines[moduleName](payload),
                navigationStack
            )

            if result.payload == 'back' then
                table.remove(navigationStack)
                if #navigationStack == 0 then
                    table.insert(navigationStack, modules[1].name)
                end
            end

            processor.push('to-core', result)
        end
    end
end

return gui
