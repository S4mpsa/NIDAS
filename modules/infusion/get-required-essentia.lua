-- Import section

local getMatrix = require("server.usecases.get-machine")

--

local function exec(address)
    local matrix = getMatrix(address, nil, nil, require("server.entities.mocks.mock-matrix"))
    if not matrix.address then
        return {}
    end

    -- TODO: event-based, non-blocking code
    local aspects
    while type(aspects) ~= "table" do
        aspects = matrix.getAspects().aspects
        os.sleep(0)
    end

    local formattedAspects = {}
    for _, aspectTable in ipairs(aspects) do
        formattedAspects[aspectTable.name] = aspectTable.amount
    end

    return formattedAspects
end

return exec
