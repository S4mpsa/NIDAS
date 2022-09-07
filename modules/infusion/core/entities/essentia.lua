---@class Essentia
---@field amount number
---@field name string
local Essentia = {}

local function tostring(essentiaListTable)
    local essentiaString = ''
    for _, essentia in ipairs(essentiaListTable) do
        essentiaString = essentiaString .. '\n' .. essentia.name .. ': ' .. essentia.amount
    end
    return essentiaString
end

local function subtraction(t1, t2)
    local result = {}
    for _, essentia1 in ipairs(t1) do
        table.insert(result, { name = essentia1.name, amount = essentia1.amount })
        for _, essentia2 in ipairs(t2) do
            if essentia2.name == essentia1.name then
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
    return setmetatable(result, { __tostring = tostring })
end

local mt = { __sub = subtraction, __tostring = tostring }

---@param aspects table
---@return Essentia[]
function Essentia.new(aspects)
    if type(aspects) ~= "table" then
        aspects = {}
    end
    for i, aspect in ipairs(aspects) do
        aspects[i] = { amount = aspect.amount, name = aspect.label or (aspect.name .. ' Gas') }
    end
    return setmetatable(aspects, mt)
end

return Essentia
