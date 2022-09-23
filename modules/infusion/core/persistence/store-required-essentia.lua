local serialization = require('serialization')

---Persists the required essentia for a given pattern
---@param pattern Pattern
---@param essentia Essentia
local function storeRequiredEssentia(pattern, essentia)
    local file = io.open('data/required-essentia.data', 'w')
    local knownRequiredEssentia = serialization.unserialize(
        file:read('*a') or '{}'
    ) or {}
    knownRequiredEssentia[pattern.outputs[1].name] = essentia

    file:write(serialization.serialize(knownRequiredEssentia))
    file:close()
end

return storeRequiredEssentia
