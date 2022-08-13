local function findPattern(knownAltars)
    if #knownAltars < 1 then
        return
    end

    local allPatterns = {}
    for _, altar in ipairs(knownAltars) do
        local patterns = altar.meInterface.getPatterns()
        for _, pattern in ipairs(patterns) do
            allPatterns[pattern] = altar
        end
    end

    local allItems = knownAltars[1].meInterface.allItems
    for item in allItems() do
        for pattern, altar in ipairs(allPatterns) do
            local allFulfilled = true
            for _, input in ipairs(pattern.inputs) do
                if input.name == item.label and input.count <= item.size then
                    input.fulfilled = true
                end
                allFulfilled = allFulfilled and input.fulfilled
            end
            if allFulfilled then
                return pattern, altar
            end
        end
    end
end

return findPattern
