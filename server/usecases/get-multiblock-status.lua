-- Import section

local status = require("server.entities.status")

local getMachine = require("get-machine")
local getNumberOfProblems = require("get-number-of-problems")
local getEnergyUsage = require("get-energy-usage")
local getEfficiencyPercentage = require("get-efficiency-percentage")

--

local function exec(address, name)
    local multiblock = getMachine(address, name)
    if string.len(multiblock.address) == 0 then
        return multiblock
    end

    local problems = getNumberOfProblems(multiblock)

    local state = {}
    if multiblock:isWorkAllowed() then
        if multiblock:hasWork() then
            state = status.states.ON
        else
            state = status.states.IDLE
        end
    else
        state = status.states.OFF
    end

    if problems > 0 then
        state = status.states.BROKEN
    end

    status = {
        progress = multiblock.getWorkProgressProgress(),
        maxProgress = multiblock.getWorkMaxProgressProgress(),
        problems = problems,
        probablyUses = getEnergyUsage(multiblock),
        efficiencyPercentage = getEfficiencyPercentage(multiblock),
        state = state
    }
    return status
end

return exec
