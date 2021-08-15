-- Import section

Colors = require("lib.graphics.colors")

--

local states = {
    ON = {name = "ON"},
    IDLE = {name = "IDLE"},
    OFF = {name = "OFF"},
    BROKEN = {name = "BROKEN"},
    MISSING = {name = "NOT FOUND"}
}

local status = {
    progress = 0,
    maxProgress = 0,
    problems = 0,
    probablyUses = 0,
    efficiencyPercentage = 0,
    state = states.OFF,
    states = states
}

return status
