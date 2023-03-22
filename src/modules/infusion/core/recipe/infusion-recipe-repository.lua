local serialization = require('serialization')
local filesystem = require('filesystem')
local Essentia = require('modules.infusion.core.altar.matrix.essentia')

local dataDir = '/home/NIDAS/data/'
filesystem.makeDirectory(dataDir)
local filePath = dataDir .. 'required-essentia.data'

local RecipeRepository = {}

---Gets the persisted required essentia for a given pattern
---@param pattern Pattern
---@return Essentia[]
function RecipeRepository.findByPattern(pattern)
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

    ---@diagnostic disable-next-line: return-type-mismatch
    return Essentia.new(knownRequiredEssentia[pattern.outputs[1].name])
end

---Persists the required essentia for a given pattern
---@param recipe InfusionRecipe
function RecipeRepository.upsert(recipe)
    local file = io.open(filePath, 'w')
    local knownRequiredEssentia = serialization.unserialize(
        file:read('*a') or '{}'
    ) or {}
    knownRequiredEssentia[recipe.pattern.outputs[1].name]
        = recipe.requiredEssentia

    file:write(serialization.serialize(knownRequiredEssentia))
    file:close()
end

return RecipeRepository
