-- Import section

local inherits = require("utils.inherits")
local mockMachine = require("server.entities.mocks.mock-machine")

--

local MockLSC =
    inherits(
    mockMachine,
    {
        name = "MockLSC"
    }
)

function MockLSC.getSensorInformation()
    return {
        "§eOperational Data:§r",
        "Used Capacity: 13,975,978,615EU",
        "Total Capacity: 9,223,372,041,254,775,807EU",
        "Passive Loss: 1,328EU/t",
        "EU IN: 32,768EU/t",
        "EU OUT: 0EU/t",
        "Avg EU IN: 0EU/t",
        "Avg EU OUT: 0EU/t",
        "Maintenance Status: §aWorking perfectly§r",
        "---------------------------------------------",
        n = 10
    }
end

return MockLSC
