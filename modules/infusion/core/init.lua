local getRecipeToInfuse = require('modules.infusion.core.usecases.get-recipe-to-infuse')
local makeInfuseFunction = require('modules.infusion.core.usecases.make-infuse-function')
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

local infusionCoroutine = coroutine.create(function()
    ---@type Altar
    local altar
    ---@type InfusionRecipe
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
            altar, recipeToInfuse = getRecipeToInfuse()
            coroutine.yield((altar or {}).id, coreStatuses.no_infusions)
        end

        if altar and recipeToInfuse then
            ongoingInfusions[altar.id] = coroutine.create(
                makeInfuseFunction(altar, recipeToInfuse)
            )
            nOngoingInfusions = nOngoingInfusions + 1

            coroutine.yield(
                altar.id,
                coreStatuses.infusion_start,
                recipeToInfuse.pattern.outputs[1].name
            )
            altar, recipeToInfuse = nil, nil
        end
    end
end)

return { 'Infusion automation', infusionCoroutine }
