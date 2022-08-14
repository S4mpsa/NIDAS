local getRequiredEssentia = require('modules.infusion.core.persistence.get-required-essentia')
local findPatterns = require('modules.infusion.core.usecases.find-patterns')

local function getRecipeToInfuse(knownAltars)
    local pattern, altar = findPatterns(knownAltars)
    if not pattern then
        return nil
    end
    local requiredEssentia = getRequiredEssentia(pattern)
    return { altar = altar, pattern = pattern, requiredEssentia = requiredEssentia }
end

return getRecipeToInfuse
