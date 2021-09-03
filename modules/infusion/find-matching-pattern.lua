-- Import section

local component = require("component")

--
local maxInterfaceSlots = 36

-- TODO: Get interface from getMachine
local function exec(itemsInChest)
    -- Runs if there's an item in the chest
    if #itemsInChest > 0 then
        -- Searches each slot of the interface for a matching pattern
        local slot = 1
        local pattern = component.me_interface.getInterfacePattern(slot)
        local patternFound = false
        while slot <= maxInterfaceSlots do
            -- Checks all patterns inputs
            patternFound = pattern and true
            for _, input in ipairs(pattern and pattern.inputs or {}) do
                -- Searches for a matching item in the chest for the pattern input
                if input.name then
                    local inputMatch = false
                    for _, item in ipairs(itemsInChest) do
                        if input.name == item.label and input.count <= item.size then
                            inputMatch = true
                            break
                        end
                    end

                    patternFound = patternFound and inputMatch
                end
            end

            if patternFound then
                return pattern
            end

            pattern = component.me_interface.getInterfacePattern(slot)
            slot = slot + 1
        end
    end
end

return exec
