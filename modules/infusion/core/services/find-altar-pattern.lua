---Returns an `altar`'s pattern if there are enough items to craft it
---@param altar Altar
---@return Pattern | nil
local function findAltarPattern(altar)
    local patterns = altar.getPatterns()
    for _, pattern in ipairs(patterns) do
        local allPatternInputsFulfilled = true

        for _, input in ipairs(pattern.inputs) do
            if input.name then
                local item = altar.getItem(input.name)
                if not item
                    or (input.count and input.count > item.size) then
                    allPatternInputsFulfilled = false
                    break
                end
            end
        end

        if allPatternInputsFulfilled then
            return pattern
        end
    end
    return nil
end

return findAltarPattern
