-- Import section
local parser = require("utils.parser")

local states = require("server.entities.states")

local getMachine = require("server.usecases.get-machine")
local getNumberOfProblems = require("server.usecases.get-number-of-problems")

--

local function exec(address, name)
    local lsc = getMachine(address, name)
    if string.len(lsc.address) == 0 then return lsc end

    local sensorInformation = lsc:getSensorInformation()

    --local problems = getNumberOfProblems(sensorInformation[9])
    local problems = sensorInformation[9]
    
    local state = {}
    if lsc:isWorkAllowed() then
        if lsc:hasWork() then
            state = states.ON
        else
            state = states.IDLE
        end
    else
        state = states.OFF
    end

    --if (problems or 0) > 0 then state = states.BROKEN end
    if string.match(problems, "Problems") ~= nil then
        state = states.BROKEN
    end
    
    local status = {
        storedEU = lsc:getStoredEU(),
        EUCapacity = lsc:getEUCapacity(),
        problems = problems,
        passiveLoss = lsc:getWorkMaxProgress() and
            parser.getInteger(sensorInformation[4]) or 0,
        state = state
    }
    return status
end

return exec
