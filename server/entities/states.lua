-- Import section

Colors = require("graphics.colors")

--

local states = {
    ON = {name = "ON", color = Colors.workingColor},
    IDLE = {name = "IDLE", color = Colors.idleColor},
    OFF = {name = "OFF", color = Colors.offColor},
    BROKEN = {name = "BROKEN", color = Colors.errorColor},
    MISSING = {name = "NOT FOUND", color = Colors.errorColor}
}

return states
