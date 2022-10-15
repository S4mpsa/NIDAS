local getRecipeToInfuse = require('modules.infusion.core.usecases.get-recipe-to-infuse')
local makeInfuseFunction = require('modules.infusion.core.usecases.make-infuse-function')
local coreStatuses = require('modules.infusion.constants').coreStatuses

local function resumeOngoingInfusions(ongoingInfusions)
    for index, infusion in ipairs(ongoingInfusions) do
        if coroutine.status(infusion) == 'dead' then
            table.remove(ongoingInfusions, index)
            coroutine.yield('dead')
        else
            local _,
                message,
                complement1,
                complement2,
                complement3 = coroutine.resume(infusion)
            coroutine.yield(message, complement1, complement2, complement3)
        end
    end
    return ongoingInfusions
end

local infusionCoroutine = coroutine.create(function()
    ---@type InfusionRecipe
    local altar, recipeToInfuse
    local ongoingInfusions = {}
    while true do
        if #ongoingInfusions > 0 then
            ongoingInfusions = resumeOngoingInfusions(ongoingInfusions)
        else
            altar, recipeToInfuse = getRecipeToInfuse()
            coroutine.yield(coreStatuses.no_infusions)
        end

        if recipeToInfuse then
            table.insert(
                ongoingInfusions,
                coroutine.create(makeInfuseFunction(altar, recipeToInfuse))
            )
            coroutine.yield(
                coreStatuses.infusion_start,
                recipeToInfuse.pattern.outputs[1].name
            )
            altar, recipeToInfuse = nil, nil
        end
    end
end)

return { 'Infusion automation', infusionCoroutine }
