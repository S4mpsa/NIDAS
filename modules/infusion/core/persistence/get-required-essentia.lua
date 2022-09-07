local serialization = require('serialization')

---Gets the persisted required essentia for a given pattern
---@param pattern Pattern
---@return Essentia[]
local function getRequiredEssentia(pattern)
    local file = io.open("data/required-essentia.data", "r")
    local knownRequiredEssentia = serialization.unserialize(file:read("*a") or '{}') or {}
    file:close()

    return knownRequiredEssentia[pattern.outputs[1].name]
end

return getRequiredEssentia
