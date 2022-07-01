-- Import section

local component = require("component")

--

local knownMachines = {}

local function exec(partialAdress, name, location, mock)
    mock = mock or require("server.entities.mocks.mock-machine")

    local address = component.get(partialAdress)
    local machine =
        (address and component.proxy(address)) or -- Exists
        (component.list("ocemu", true)() and mock:getMock(partialAdress)) or -- Is running on emulator
        {} -- Is missing

    machine.name = name or "Unnamed"
    machine.location = location or {}
    knownMachines[partialAdress] = machine

    return knownMachines[partialAdress]
end

return exec
