local coreStatuses = require('modules.infusion.constants').coreStatuses

---Waits for a read from the `recipe`'s `altar` and returns the read `essentia`
---@param altar Altar
---@param recipe InfusionRecipe
---@return Essentia[] essentia
local function waitForAltarReading(altar, recipe)
    local requiredEssentia = recipe.requiredEssentia

    local essentia = altar.readMatrix()
    while not essentia or #essentia == 0 do
        essentia = altar.readMatrix()
        coroutine.yield(
            altar.id,
            coreStatuses.waiting_on_matrix,
            '',
            requiredEssentia,
            requiredEssentia
        )
    end
    return essentia
end

return waitForAltarReading
