local coreStatuses = require("modules.infusion.constants").coreStatuses

---Waits for the `altar` to have an item on it's center pedestal
---@param altar Altar
---@param recipe InfusionRecipe
local function waitForPedestalItem(altar, recipe)
    local pedestalItem = altar.getPedestalItem()
    while not pedestalItem do
        pedestalItem = altar.getPedestalItem()
        local outputName = recipe.pattern.outputs[1].name
        coroutine.yield(
            altar.id,
            coreStatuses.infusion_start,
            outputName
        )
    end
end

return waitForPedestalItem
