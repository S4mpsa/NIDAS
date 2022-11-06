local coreStatuses = require('modules.infusion.constants').coreStatuses

---Waits for the `recipe`'s `altar`
---to have at least as much essentia as the `recipe`'s `requiredEssentia`
---@param altar Altar
---@param recipe InfusionRecipe
local function waitForRequiredEssentia(altar, recipe)
    local outputName = recipe.pattern.outputs[1].name
    local requiredEssentia = recipe.requiredEssentia

    local missingEssentia = requiredEssentia - altar.getStoredEssentia()
    -- TODO: find a way to cancel dangling essentia crafts on the ME system CPUs
    -- altar.requestEssentia(missingEssentia)
    while #missingEssentia > 0 do
        coroutine.yield(
            altar.id,
            coreStatuses.missing_essentia,
            outputName,
            requiredEssentia,
            requiredEssentia - missingEssentia
        )
        missingEssentia = requiredEssentia - altar.getStoredEssentia()
    end
end

return waitForRequiredEssentia
