local event = require('event')

local getKnownAltars = require('modules.infusion.core.usecases.get-known-altars')
local getRecipeToInfuse = require('modules.infusion.core.usecases.get-recipe-to-infuse')
local makeInfuseFunction = require('modules.infusion.core.usecases.make-infuse-function')

local knownAltars = getKnownAltars()
event.listen("altars_update", function(_, updatedAltars)
    knownAltars = updatedAltars
end)

local infusionCoroutine = coroutine.create(function()
    while true do
        local infusionsInProgress = {}
        local recipeToInfuse
        while not recipeToInfuse do
            for _, infusion in ipairs(infusionsInProgress) do
                coroutine.yield(coroutine.resume(infusion))
            end
            recipeToInfuse = getRecipeToInfuse(knownAltars)
            coroutine.yield()
        end

        table.insert(infusionsInProgress, coroutine.create(makeInfuseFunction(recipeToInfuse)))
    end
end)

return { 'Infusion automation', infusionCoroutine }
