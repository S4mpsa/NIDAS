-- Import section

local getInterface = require("server.usecases.get-machine")

--

local maxInterfaceSlots = 36

local function exec(itemsInChest, address)
    local meInterface = getInterface(address)
    if not meInterface.address then
        return
    end

    -- Runs if there's an item in the chest
    if #itemsInChest > 0 then
        -- Searches each slot of the interface for a matching pattern
        local patternFound = false
        for slot = 1, maxInterfaceSlots do
            local pattern = meInterface.getInterfacePattern(slot)
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
                    if not patternFound then
                        break
                    end
                end
            end

            if patternFound then
                return pattern
            end
        end
    end
end

return exec
