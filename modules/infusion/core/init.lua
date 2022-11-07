local getRecipeToInfuse = require('modules.infusion.core.services.get-recipe-to-infuse')
local AltarRepository = require('modules.infusion.core.altar.altar-repository')
local resumeInfusion = require('modules.infusion.core.usecases.resume-infusion')
local startInfusion = require('modules.infusion.core.usecases.start-infusion')
local coreStatuses = require('modules.infusion.constants').coreStatuses

local infusionAutomation = function()
    while true do
        for _, altar in ipairs(AltarRepository.getAll()) do
            local recipe = getRecipeToInfuse(altar)
            if altar.getPedestalItem() then
                recipe = altar.currentRecipe
                resumeInfusion(altar, recipe)
                altar.currentRecipe = nil
            elseif recipe then
                altar.currentRecipe = recipe
                startInfusion(altar, recipe)
            else
                coroutine.yield(
                    altar.id,
                    coreStatuses.no_infusions
                )
            end
        end
    end
end

return infusionAutomation
