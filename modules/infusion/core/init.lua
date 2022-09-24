local getRecipeToInfuse = require('modules.infusion.core.usecases.get-recipe-to-infuse')
local makeInfuseFunction = require('modules.infusion.core.usecases.make-infuse-function')

local function resumeOngoingInfusions(ongoingInfusions)
    for index, infusion in ipairs(ongoingInfusions) do
        if coroutine.status(infusion) == 'dead' then
            table.remove(ongoingInfusions, index)
            coroutine.yield('dead')
        else
            local _, message, complement = coroutine.resume(infusion)
            coroutine.yield(message, complement)
        end
    end
    return ongoingInfusions
end

local infusionCoroutine = coroutine.create(function()
    ---@type InfusionRecipe
    local recipeToInfuse
    local ongoingInfusions = {}
    while true do
        if #ongoingInfusions > 0 then
            ongoingInfusions = resumeOngoingInfusions(ongoingInfusions)
        else
            recipeToInfuse = getRecipeToInfuse()
            coroutine.yield('No ongoing infusions')
        end

        if recipeToInfuse then
            table.insert(
                ongoingInfusions,
                coroutine.create(makeInfuseFunction(recipeToInfuse))
            )
            recipeToInfuse = nil
            coroutine.yield('Starting infusion')
        end
    end
end)

return { 'Infusion automation', infusionCoroutine }
