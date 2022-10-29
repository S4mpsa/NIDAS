local getRecipeToInfuse = require('modules.infusion.core.services.get-recipe-to-infuse')
local infuse = require('modules.infusion.core.services.infuse')
local coreStatuses = require('modules.infusion.constants').coreStatuses

local function resumeOngoingInfusions(ongoingInfusions, nOngoingInfusions)
    for altarId, infusion in pairs(ongoingInfusions) do
        if coroutine.status(infusion) == 'dead' then
            ongoingInfusions[altarId] = nil
            nOngoingInfusions = nOngoingInfusions - 1
            coroutine.yield(altarId, 'dead')
        else
            local args = { coroutine.resume(infusion) }
            args[1] = altarId
            coroutine.yield(table.unpack(args))
        end
    end

    return ongoingInfusions, nOngoingInfusions
end

local infusionAutomationCoroutine = coroutine.create(function()
    ---@type InfusionRecipe | nil
    local recipeToInfuse
    local ongoingInfusions = {}
    local nOngoingInfusions = 0
    while true do
        if nOngoingInfusions > 0 then
            ongoingInfusions, nOngoingInfusions = resumeOngoingInfusions(
                ongoingInfusions,
                nOngoingInfusions
            )
        else
            recipeToInfuse = getRecipeToInfuse()
            coroutine.yield('', coreStatuses.no_infusions)
        end

        if recipeToInfuse then
            local recipeCopy = table.unpack({ recipeToInfuse })
            ongoingInfusions[recipeToInfuse.altar.id] = coroutine.create(
                function ()
                    infuse(recipeCopy)
                end
            )
            nOngoingInfusions = nOngoingInfusions + 1

            coroutine.yield(
                recipeToInfuse.altar.id,
                coreStatuses.infusion_start,
                recipeToInfuse.pattern.outputs[1].name
            )
            recipeToInfuse = nil
        end
    end
end)

return { 'Infusion automation', infusionAutomationCoroutine }
