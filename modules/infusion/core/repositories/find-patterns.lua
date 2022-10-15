local event = require('event')

local getKnownAltars = require('modules.infusion.core.repositories.get-known-altars')
local knownAltars = getKnownAltars()
event.listen('altars_update', function(_, updatedAltars)
    knownAltars = updatedAltars
end)

---comment
---@return Pattern
---@return Altar
local function findPatterns()
    for _, altar in ipairs(knownAltars) do
        if not altar.getPedestalItem() then
            local patterns = altar.getPatterns()
            for _, pattern in ipairs(patterns) do
                local allFulfilled = true

                for _, input in ipairs(pattern.inputs) do
                    if input.name then
                        local item = altar.getItem(input.name)
                        if not item
                            or (input.count and input.count > item.size) then
                            allFulfilled = false
                            break
                        end
                    end
                end

                if allFulfilled then
                    return pattern, altar
                end
            end
        end
    end
end

return findPatterns