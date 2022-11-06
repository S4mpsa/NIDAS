local RecipeRepository = require('modules.infusion.core.repositories.infusion-recipe-repository')
local findAltarPattern = require('modules.infusion.core.services.find-altar-pattern')

---Returns an eligible recipe to be infused
---@param altar Altar
---@return InfusionRecipe | nil recipe
local function getRecipeToInfuse(altar)
    ---@type Pattern | false | nil
    local pattern = not altar.getPedestalItem() and findAltarPattern(altar)
    if pattern
        and pattern.outputs
        and pattern.outputs[1]
        and pattern.outputs[1].name
        and pattern.inputs
        and pattern.inputs[1]
        and pattern.inputs[1].name then

        return {
            pattern = pattern,
            requiredEssentia = RecipeRepository.findByPattern(pattern)
        }
    end
    return nil
end

return getRecipeToInfuse
