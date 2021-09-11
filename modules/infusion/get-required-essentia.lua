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
    -- The first aspect will have one unit added to it in case there was enough essentia in the system to drain one from it before getAspects() could be run
    formattedAspects[aspects[1].name] = aspects[1].amount + 1
    for i = 2, #aspects do
        formattedAspects[aspects[i].name] = aspects[i].amount
    end

    return formattedAspects
end

return exec
