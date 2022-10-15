local serialization = require('serialization')
local filesystem = require('filesystem')

filesystem.makeDirectory('/home/NIDAS/data')

---Gets the persisted required essentia for a given pattern
---@param pattern Pattern
---@return Essentia[]
local function getRequiredEssentia(pattern)
    local filePath = 'data/required-essentia.data'
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

return {
    getRequiredEssentia = getRequiredEssentia,
    storeRequiredEssentia = storeRequiredEssentia,
}
