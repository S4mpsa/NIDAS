local storeRequiredEssentia = require('modules.infusion.core.usecases.store-required-essentia')

---comment
---@param recipeToInfuse InfusionRecipe
---@return function
local function makeInfuseFunction(recipeToInfuse)
    return function()
        local altar = recipeToInfuse.altar
        local meInterface = altar.meInterface

        local craft = meInterface.requestCraft(recipeToInfuse)

        local requiredEssentia = recipeToInfuse.requiredEssentia
        if not requiredEssentia then
            altar.blockEssentiaProvider()
            altar.activateMatrix()
            local essentia = altar.readMatrix()
            storeRequiredEssentia(recipeToInfuse, essentia)
            altar.unblockEssentiaProvider()
        end

        local missingEssentia = meInterface.getStoredEssentia() - requiredEssentia
        meInterface.requestCraft(missingEssentia)
        while missingEssentia do
            missingEssentia = meInterface.getStoredEssentia() - requiredEssentia
            coroutine.yield("waiting_on_essentia", missingEssentia)
        end

        altar.activateMatrix()

        while not craft.isDone() or craft.isCanceled() do
            coroutine.yield("waiting_on_infusion", altar.readMatrix())
        end

        altar.retireveCraftedItem()
    end
end

return makeInfuseFunction
