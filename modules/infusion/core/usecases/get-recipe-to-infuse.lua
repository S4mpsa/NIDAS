local getRequiredEssentia = require('modules.infusion.core.persistence.get-required-essentia')
local findPatterns = require('modules.infusion.core.usecases.find-patterns')


local knownRecipes = {}
---Returns the next available recipe to be infused
---@return InfusionRecipe recipeToInfuse
local function getRecipeToInfuse()
    local pattern, altar = findPatterns()
    if not pattern
        or not pattern.outputs
        or not pattern.outputs[1]
        or not pattern.outputs[1].name then
        return nil
    end

    if not knownRecipes[altar.id .. pattern.outputs[1].name] then
        local requiredEssentia = getRequiredEssentia(pattern)
        knownRecipes[altar.id .. pattern.outputs[1].name] = {
            altar = altar,
            pattern = pattern,
            requiredEssentia = requiredEssentia,
        }
    end

    return knownRecipes[altar.id .. pattern.outputs[1].name]
end

return getRecipeToInfuse
