local storeRequiredEssentia = require('modules.infusion.core.persistence.store-required-essentia')

---comment
---@param recipeToInfuse InfusionRecipe
---@return function
local function makeInfuseFunction(recipeToInfuse)
    return function()
        local altar = recipeToInfuse.altar
        altar.requestCraft(recipeToInfuse.pattern.outputs[1])

        local requiredEssentia = recipeToInfuse.requiredEssentia
        if not requiredEssentia then
            altar.blockEssentiaProvider()
            altar.activateMatrix()
            local essentia = altar.readMatrix()
            storeRequiredEssentia(recipeToInfuse.pattern, essentia)
            altar.unblockEssentiaProvider()
        end

        local missingEssentia = altar.getStoredEssentia() - requiredEssentia
        altar.requestEssentia(missingEssentia)
        while missingEssentia do
            missingEssentia = altar.getStoredEssentia() - requiredEssentia
            coroutine.yield("waiting_on_essentia", missingEssentia)
        end

        altar.activateMatrix()

        while altar.isBusy() do
            coroutine.yield("waiting_on_infusion", altar.readMatrix())
        end

        altar.retireveCraftedItem()
    end
end

return makeInfuseFunction
