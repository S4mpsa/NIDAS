local frame = require('gui.components.molecules.frame')
local engine = require('gui.core.engine')

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

        centerComponent, navigationStack = coroutine.yield()
    end
end)

local gui = {}

---@param modules Module[]
---@param processor EventProcessor
---@return fun(payload: table?)
function gui.new(modules, processor)
    local navigationStack = {
        modules[1].name,
    }

    local wrappedCoroutines = {}
    for _, module in ipairs(modules) do
        wrappedCoroutines[module.name] = wrap(
            module.gui,
            module.name .. '/gui',
            true
        )
    end

    return function(incomingPayload)
        incomingPayload = incomingPayload or {}
        local moduleName = incomingPayload.name
        incomingPayload.name = nil
        local currentScreen = navigationStack[#navigationStack]
        if not moduleName or
            moduleName == currentScreen and wrappedCoroutines[moduleName]
        then
            ---@type Component
            local centerComponent = wrappedCoroutines[currentScreen](
                table.unpack(incomingPayload)
            )[1]
            ---@type Event
            local outgoingPayload = main(centerComponent, navigationStack)
            outgoingPayload.name = currentScreen

            if outgoingPayload[1] == 'back' then
                table.remove(navigationStack)
                if #navigationStack == 0 then
                    table.insert(navigationStack, modules[1].name)
                end
            end

            processor.push('to-core', { payload = outgoingPayload })
        end
    end
end

return gui
