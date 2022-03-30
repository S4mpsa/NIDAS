-- Import section
local parser = require "lib.utils.parser"

local states = require("server.entities.states")

local getMachine = require("server.usecases.get-machine")
local getNumberOfProblems = require("server.usecases.get-number-of-problems")
local getEfficiencyPercentage = require("server.usecases.get-efficiency-percentage")

--

local function exec(address, name, location)
    local multiblock = getMachine(address, name, location)
    if not multiblock.address then
        multiblock.state = states.MISSING
        return multiblock
    end
    local sensorInformation = multiblock:getSensorInformation()

    local gtPlusPlus = string.match(sensorInformation[5] or "", "EU") and 7 or 5
    if gtPlusPlus == 7 then gtPlusPlus = string.match(sensorInformation[18] or "", "Problems") and 18 or 7 end
    local problems = getNumberOfProblems(sensorInformation[gtPlusPlus])

    local state = {}
    if multiblock:isWorkAllowed() then
        if multiblock:hasWork() then
            state = states.ON
        else
            state = states.IDLE
        end
    else
        state = states.OFF
    end

    if problems > 0 then
        state = states.BROKEN
    end

    local status = {
        name = name,
        state = state,
        progress = multiblock.getWorkProgress(),
        maxProgress = multiblock.getWorkMaxProgress(),
        problems = problems,
        probablyUses = multiblock.getWorkMaxProgress() and parser.getInteger(sensorInformation[3]) or 0,
        efficiencyPercentage = getEfficiencyPercentage(sensorInformation[5]),
        location = location
    }
    return status
end

return exec
