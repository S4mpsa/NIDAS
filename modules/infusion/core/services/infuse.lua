local storeRequiredEssentia = require('modules.infusion.core.repositories.required-essentia').storeRequiredEssentia
local coreStatuses = require('modules.infusion.constants').coreStatuses

---Waits for a read from the `recipe`'s `altar` and returns the read `essentia`
---@param recipe InfusionRecipe
---@return Essentia[] essentia
local function readAltar(recipe)
    local altar = recipe.altar
    local requiredEssentia = recipe.requiredEssentia

    local essentia = altar.readMatrix()
    while #essentia == 0 do
        essentia = altar.readMatrix()
        coroutine.yield(
            coreStatuses.waiting_on_matrix,
            '',
            requiredEssentia,
            requiredEssentia
        )
    end
    return essentia
end

---Waits for the `recipe`'s `altar` 
---to have at least as much essentia as the `recipe`'s `requiredEssentia`
---@param recipe InfusionRecipe
local function waitForEssentia(recipe)
    local altar = recipe.altar
    local outputName = recipe.pattern.outputs[1].name
    local requiredEssentia = recipe.requiredEssentia

    local missingEssentia = requiredEssentia - altar.getStoredEssentia()
    -- TODO: find a way to cancel dangling essentia crafts on the ME system CPUs
    -- altar.requestEssentia(missingEssentia)
    while #missingEssentia > 0 do
        coroutine.yield(
            coreStatuses.missing_essentia,
            outputName,
            requiredEssentia,
            requiredEssentia - missingEssentia
        )
        missingEssentia = requiredEssentia - altar.getStoredEssentia()
    end
end

---Waits for the `altar` to have an item on it's center pedestal
---@param altar Altar
local function waitForPedestalItem(altar)
    local pedestalItem = altar.getPedestalItem()
    while not pedestalItem do
        pedestalItem = altar.getPedestalItem()
    end
end

---Waits for the infusion of a `recipe` to finish
---@param recipe InfusionRecipe
local function waitForInfusion(recipe)
    local altar = recipe.altar
    local inputName = recipe.pattern.inputs[1].name
    local outputName = recipe.pattern.outputs[1].name
    local requiredEssentia = recipe.requiredEssentia

    local pedestalItemLabel = (altar.getPedestalItem() or {}).label
    while inputName == pedestalItemLabel do
        coroutine.yield(
            coreStatuses.waiting_on_essentia,
            outputName,
            requiredEssentia,
            altar.readMatrix()
        )
        pedestalItemLabel = (altar.getPedestalItem() or {}).label
    end
    if pedestalItemLabel ~= outputName then
        print('Infused item "'
            .. tostring(pedestalItemLabel)
            .. '" does not match pattern output "'
            .. outputName
            .. '".'
        )
    end
end

---Infuses a particular recipe
---@param recipe InfusionRecipe
local function infuse(recipe)
    local altar = recipe.altar
    local patternOutput = recipe.pattern.outputs[1]
    local requiredEssentia = recipe.requiredEssentia

    if requiredEssentia and (#requiredEssentia > 0) then
        waitForEssentia(recipe)

        altar.unblockEssentiaProvider()

        altar.requestCraft(patternOutput)
        altar.activateMatrix()
        waitForPedestalItem(altar)
        readAltar(recipe)
    else
        altar.blockEssentiaProvider()

        altar.requestCraft(patternOutput)
        waitForPedestalItem(altar)
        altar.activateMatrix()
        recipe.requiredEssentia = readAltar(recipe)
        storeRequiredEssentia(recipe.pattern, recipe.requiredEssentia)

        altar.unblockEssentiaProvider()
    end

    waitForInfusion(recipe)
    altar.retrieveCraftedItem(patternOutput)
end

return infuse
