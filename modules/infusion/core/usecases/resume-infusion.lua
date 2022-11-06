local waitForInfusion = require('modules.infusion.core.services.wait-for-infusion')

---Infuses a recipe on an altar
---@param altar Altar
---@param recipe InfusionRecipe?
local function resumeInfusion(altar, recipe)
    waitForInfusion(altar, recipe)
    altar.retrieveCraftedItem()
end

return resumeInfusion
