local getRequiredEssentia = require('modules.infusion.core.repositories.required-essentia').getRequiredEssentia
local getKnownAltars = require('modules.infusion.core.repositories.get-known-altars')
local findAltarPattern = require('modules.infusion.core.services.find-altar-pattern')

---Returns an eligible recipe to be infused
---@return InfusionRecipe recipe
local function getRecipeToInfuse()
    ---@type Altar
    for _, altar in ipairs(getKnownAltars()) do
        ---@type Pattern
        local pattern = not altar.getPedestalItem() and findAltarPattern(altar)

        if pattern
            and pattern.outputs
            and pattern.outputs[1]
            and pattern.outputs[1].name
            and pattern.inputs
            and pattern.inputs[1]
            and pattern.inputs[1].name then

            return {
                altar = altar,
                pattern = pattern,
                requiredEssentia = getRequiredEssentia(pattern)
            }
        end
    end
end

return getRecipeToInfuse
