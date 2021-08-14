-- Import section
local component = require("component")
local new = require("lib.utils.new")

local findInIterator = require("lib.utils.find-in-iterator")
local machineEntity = require("server.entities.machine")

--

local knownMachines = {}

local function exec(partialAdress, name, mock)
    mock = mock or require("server.entities.mocks.mock-machine")
    if not knownMachines[partialAdress] then
        local address = component.get(partialAdress)

        local machineComponent =
            (address and component.proxy(address)) or -- Exists
            (findInIterator(component.list(), "ocemu") and mock:new(partialAdress)) or -- Is running on emulator
            {}

        knownMachines[partialAdress] = new(machineEntity, machineComponent, {name = name})
    end

    return knownMachines[partialAdress]
end

return exec
