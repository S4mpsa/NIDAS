---Gets the required essentia for an ongoing infusion
---@param matrix matrix
---@return essentia[]
local function getRequiredEssentia(matrix, infusionProviderRedstone)
    if not matrix.address then error("Missing runic matrix!") end

    -- TODO: event-based, non-blocking code
    local aspects
    while type(aspects) ~= "table" do
        aspects = matrix.update().aspects
        os.sleep(1)
    end

    infusionProviderRedstone.setOutput({0, 0, 0, 0, 0, 0})

    local formattedAspects = {}
    for _, aspect in ipairs(aspects) do
        formattedAspects[aspect.name] = aspect.amount
    end

    return formattedAspects
end

return getRequiredEssentia
