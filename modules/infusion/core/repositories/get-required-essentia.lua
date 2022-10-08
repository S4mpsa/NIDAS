local serialization = require('serialization')
local filesystem = require('filesystem')

filesystem.makeDirectory('/home/NIDAS/data')

---Gets the persisted required essentia for a given pattern
---@param pattern Pattern
---@return Essentia[]
local function getRequiredEssentia(pattern)
    local filePath = '/home/NIDAS/data/required-essentia.data'
    local file
    if filesystem.exists(filePath) then
        file = io.open(filePath, 'r')
    else
        file = io.open(filePath, 'w')
    end

    local knownRequiredEssentia = serialization.unserialize(
        file:read('*a') or '{}'
    ) or {}
    file:close()

    return knownRequiredEssentia[pattern.outputs[1].name]
end

return getRequiredEssentia
