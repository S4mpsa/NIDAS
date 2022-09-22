---@class Essentia
---@field amount number
---@field label string
local Essentia = {}

local function tostring(essentiaListTable)
    local essentiaString = ''
    for _, essentia in ipairs(essentiaListTable) do
        essentiaString = essentiaString .. '\n' .. essentia.label .. ': ' .. essentia.amount
    end
    return essentiaString
end

local function subtraction(t1, t2)
    local result = {}
    for _, essentia1 in ipairs(t1) do
        table.insert(result, { label = essentia1.label, amount = essentia1.amount })
        for _, essentia2 in ipairs(t2) do
            if essentia2.label == essentia1.label then
                local amount = essentia1.amount - essentia2.amount
                if amount > 0 then
                    result[#result].amount = amount
                else
                    table.remove(result)
                end
                break
            end
        end
    end
    return Essentia.new(result)
end

local mt = { __sub = subtraction, __tostring = tostring }

---@param aspects table
---@return Essentia[]
function Essentia.new(aspects)
    if type(aspects) ~= "table" then
        aspects = {}
    end
    local newAspects = {}
    for i, aspect in ipairs(aspects) do
        newAspects[i] = {
            amount = aspect.amount,
            label = aspect.label or (aspect.name .. ' Gas'),
        }
    end
    return setmetatable(newAspects, mt)
end

return Essentia
