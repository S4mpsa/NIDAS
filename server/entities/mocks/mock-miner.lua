-- Import section

local inherits = require("utils.inherits")
local mockMachine = require("server.entities.mocks.mock-machine")

--

local MockMiner =
    inherits(
    mockMachine,
    {
        name = "MockMiner"
    }
)

function MockMiner.getSensorInformation()
    return {
        "§9Multiblock Miner§r",
        "Work Area: §a2x2§r Chunks",
        n = 2
    }
end

return MockMiner
