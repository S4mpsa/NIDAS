local getRequiredEssentia = require('modules.infusion.core.usecases.get-required-essentia')
local findPattern = require('modules.infusion.core.usecases.find-pattern')

local function getRecipeToInfuse(knownAltars)
    local pattern, altar = findPattern(knownAltars)
    if not pattern then
        return nil
    end
    local requiredEssentia = getRequiredEssentia(pattern)
    return { altar = altar, pattern = pattern, requiredEssentia = requiredEssentia }
end

return getRecipeToInfuse
