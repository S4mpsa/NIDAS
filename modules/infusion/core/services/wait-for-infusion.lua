local coreStatuses = require('modules.infusion.constants').coreStatuses

---Waits for the infusion of a `recipe` to finish
---@param altar Altar
---@param recipe InfusionRecipe?
local function waitForInfusion(altar, recipe)
    local outputName = recipe and recipe.pattern.outputs[1].name or ''
    local requiredEssentia = recipe
        and recipe.requiredEssentia
        or altar.readMatrix()

    while altar.readMatrix() do
        coroutine.yield(
            altar.id,
            coreStatuses.waiting_on_infusion,
            outputName,
            requiredEssentia,
            altar.readMatrix()
        )
    end
end

return waitForInfusion
