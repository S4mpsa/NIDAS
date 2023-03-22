local RecipeRepository = require('modules.infusion.core.recipe.infusion-recipe-repository')
local waitForAltarReading = require('modules.infusion.core.services.wait-for-altar-reading')
local waitForPedestalItem = require('modules.infusion.core.services.wait-for-pedestal-item')
local waitForRequiredEssentia = require('modules.infusion.core.services.wait-for-required-essentia')

local function activateAltar(altar, recipe)
    altar.requestCraft(recipe.pattern.outputs[1])
    waitForPedestalItem(altar, recipe)
    altar.activateMatrix()
end

---Infuses a recipe on an altar
---@param altar Altar
---@param recipe InfusionRecipe
local function startInfusion(altar, recipe)
    local requiredEssentia = recipe.requiredEssentia
    if requiredEssentia and (#requiredEssentia > 0) then
        waitForRequiredEssentia(altar, recipe)

        altar.unblockEssentiaProvider()
        activateAltar(altar, recipe)
        waitForAltarReading(altar, recipe)
    else
        altar.blockEssentiaProvider()

        activateAltar(altar, recipe)
        recipe.requiredEssentia = waitForAltarReading(altar, recipe)
        RecipeRepository.upsert(recipe)

        altar.unblockEssentiaProvider()
    end
end

return startInfusion
