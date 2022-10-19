local serialization = require('serialization')
local filesystem = require('filesystem')
local Essentia = require('modules.infusion.core.dtos.essentia')

local dataDir = '/home/NIDAS/data/'
filesystem.makeDirectory(dataDir)

---Gets the persisted required essentia for a given pattern
---@param pattern Pattern
---@return Essentia[]
local function getRequiredEssentia(pattern)
    local filePath = dataDir .. 'required-essentia.data'
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

    return Essentia.new(knownRequiredEssentia[pattern.outputs[1].name])
end

---Persists the required essentia for a given pattern
---@param pattern Pattern
---@param essentia Essentia
local function storeRequiredEssentia(pattern, essentia)
    local file = io.open(dataDir .. 'required-essentia.data', 'w')
    local knownRequiredEssentia = serialization.unserialize(
        file:read('*a') or '{}'
    ) or {}
    knownRequiredEssentia[pattern.outputs[1].name] = essentia

    file:write(serialization.serialize(knownRequiredEssentia))
    file:close()
end

return {
    getRequiredEssentia = getRequiredEssentia,
    storeRequiredEssentia = storeRequiredEssentia,
}
