local serialization = require('serialization')

---Persists the required essentia for a given pattern
---@param pattern Pattern
---@param essentia Essentia
local function storeRequiredEssentia(pattern, essentia)
    local file = io.open("required-essentia.data", "w")
    local knownRequiredEssentia = serialization.unserialize(file:read("*a")) or {}
    knownRequiredEssentia[pattern.outputs[1]] = essentia

    file:write(serialization.serialize(knownRequiredEssentia))
    file:close()
end

return storeRequiredEssentia
