local serialization = require('serialization')
local Essentia = require('modules.infusion.core.entities.essentia')

---Gets the persisted required essentia for a given pattern
---@param pattern Pattern
---@return Essentia[]
local function getRequiredEssentia(pattern)
    local file = io.open("required-essentia.data", "r")
    local knownRequiredEssentia = serialization.unserialize(file:read("*a")) or {}
    file:close()

    return Essentia.new(knownRequiredEssentia[pattern.outputs[1]])
end

return getRequiredEssentia
