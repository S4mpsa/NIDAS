-- Import section

States = require("entities.states")

--

local status = {
    progress = 0,
    maxProgress = 0,
    problems = 0,
    probablyUses = 0,
    efficiencyPercentage = 0,
    state = States.MISSING,
}

return status
