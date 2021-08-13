-- Import section
local component = require("component")
local filesystem = require("filesystem")
local new = require("lib.utils.new")

local findIn = require("lib.utils.find-in")
local mock = require("server.entities.mocks.mock-machine")
local machineEntity = require("server.entities.machine")

--

local knownMachines = {}

local function exec(partialAdress, name)
    if not knownMachines[partialAdress] then
        local address = component.get(partialAdress)

        local machineComponent =
            (address and component.proxy(address)) or -- Exists
            (findIn(component.list(), "ocemu") and mock:new(partialAdress, name)) or -- Is running on emulator
            nil

        knownMachines[partialAdress] = new(machineEntity, machineComponent, {name = name})
    end

    return knownMachines[partialAdress]
end

return exec
