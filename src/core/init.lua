local wrap = require('lib.lua-extensions.wrap')

local core = {}

---@param modules Module[]
---@param processor EventProcessor
---@return fun(payload: table?)
function core.new(modules, processor)
    local wrappedCoroutines = {}
    for _, module in ipairs(modules) do
        wrappedCoroutines[module.name] = wrap(
            module.core,
            module.name .. '/core'
        )
    end

    return function(incomingPayload)
        incomingPayload = incomingPayload or {}
        for moduleName, wrappedCoroutine in pairs(wrappedCoroutines) do
            local outgoingPayload
            if incomingPayload.name == moduleName then
                outgoingPayload = wrappedCoroutine(incomingPayload)
            else
                outgoingPayload = wrappedCoroutine()
            end
            outgoingPayload.name = moduleName

            processor.push('from-core', { payload = outgoingPayload })
        end
    end
end

return core
