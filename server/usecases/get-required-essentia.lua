-- Import section

local getMatrix = require("server.usecases.get-machine")

--

local function exec(address)
    local matrix = getMatrix(address, nil, nil, require("server.entities.mocks.mock-matrix"))
    if not matrix.address then
        return {}
    end

    local aspects = matrix.getAspects().aspects
    local formattedAspects = {}
    if type(aspects) == "table" then
        for _, aspectTable in ipairs(aspects) do
            formattedAspects[aspectTable.name] = aspectTable.amount
        end
    end

    return formattedAspects
end

return exec
