local storeRequiredEssentia = require('modules.infusion.core.persistence.store-required-essentia')

---Waits for a read from the `altar` and returns the read `essentia`
---@param altar Altar
---@return Essentia[] essentia
local function waitForRead(altar)
    local essentia = altar.readMatrix()
    while #essentia == 0 do
        essentia = altar.readMatrix()
        coroutine.yield('waiting_on_matrix')
    end
    return essentia
end

---Waits for the `altar` to have at least the same essentia as the `requiredEssentia`
---@param altar Altar
---@param outputName string
---@param requiredEssentia Essentia[] essentia required for the infusion
local function waitForEssentia(altar, outputName, requiredEssentia)
    local missingEssentia = requiredEssentia - altar.getStoredEssentia()
    -- TODO: find a way to cancel dangling essentia crafts on the ME system CPUs
    -- altar.requestEssentia(missingEssentia)
    while #missingEssentia > 0 do
        coroutine.yield(
            'Missing essentia to craft "' .. outputName .. '": ',
            missingEssentia
        )
        missingEssentia = requiredEssentia - altar.getStoredEssentia()
    end
end

local function waitForPedestalItem(altar)
    local pedestalItem = altar.getPedestalItem()
    while not pedestalItem do
        pedestalItem = altar.getPedestalItem()
    end
    return pedestalItem
end

---Waits for the center pedestal item on a particular `altar` to change
---@param altar Altar
---@param outputName string
---@param previousPedestalItem ItemStack
local function waitForInfusion(altar, outputName, previousPedestalItem)
    local pedestalItemLabel = (altar.getPedestalItem() or {}).label
    while previousPedestalItem.label == pedestalItemLabel do
        coroutine.yield(
            'Remaining essentia to infuse "' .. outputName .. '": ',
            altar.readMatrix()
        )
        pedestalItemLabel = (altar.getPedestalItem() or {}).label
    end
    if pedestalItemLabel.label ~= outputName then
        print('Infused item "' 
            .. tostring(pedestalItemLabel)
            .. 'does not match pattern output "'
            .. outputName
            .. '".'
        )
    end
end

---Makes the function that controls the infusion of a particular `recipe`
---@param recipe InfusionRecipe
---@return function
local function makeInfuseFunction(recipe)
    local altar = recipe.altar
    local firstPatternOutput = recipe.pattern.outputs[1]
    local requiredEssentia = recipe.requiredEssentia

    return function()
        local previousPedestalItem
        if requiredEssentia and (#requiredEssentia > 0) then
            waitForEssentia(altar, firstPatternOutput.name, requiredEssentia)

            altar.unblockEssentiaProvider()

            altar.requestCraft(firstPatternOutput)
            altar.activateMatrix()
            previousPedestalItem = waitForPedestalItem(altar)
            waitForRead(altar)
        else
            altar.blockEssentiaProvider()

            altar.requestCraft(firstPatternOutput)
            previousPedestalItem = waitForPedestalItem(altar)
            altar.activateMatrix()
            local essentia = waitForRead(altar)
            storeRequiredEssentia(recipe.pattern, essentia)

            altar.unblockEssentiaProvider()
        end

        waitForInfusion(altar, firstPatternOutput.name, previousPedestalItem)
        altar.retrieveCraftedItem(firstPatternOutput.count)
    end
end

return makeInfuseFunction
