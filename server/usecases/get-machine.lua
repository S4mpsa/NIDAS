-- Import section

local component = require("component")

local findInIterator = require("lib.utils.find-in-iterator")

--

local knownMachines = {}

local function exec(partialAdress, name, mock)
    mock = mock or require("server.entities.mocks.mock-machine")

    local address = component.get(partialAdress)
    local machine =
        (address and component.proxy(address)) or -- Exists
        (findInIterator(component.list(), "ocemu") and mock:new(partialAdress)) or -- Is running on emulator
        {} -- Is missing

    machine.name = name
    knownMachines[partialAdress] = machine

    return knownMachines[partialAdress]
end

return exec
