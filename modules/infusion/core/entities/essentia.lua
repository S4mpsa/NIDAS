---@class Essentia
---@field amount number
---@field label string
local Essentia = {}

function Essentia.new(essentiaList)
    local mt = {
        __sub = function(_, t1, t2)
            local result = {}
            for index, essentia1 in ipairs(t1) do
                result[index] = { label = essentia1.label, amount = essentia1.amount }
                for _, essentia2 in ipairs(t2) do
                    if essentia2.label == essentia1.label then
                        result[index].amount = essentia1.amount - essentia2.amount
                        break
                    end
                end
            end
            return result
        end,
    }
    return setmetatable(essentiaList, mt)
end

return Essentia
