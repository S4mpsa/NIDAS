-- Import section
Component = require("component")
Filesystem = require("filesystem")
New = require("lib.utils.new")

local findIn = require("lib.utils.find-in")
local mock = require("server.entities.mocks.mock-machine")
local machineEntity = require("server.entities.machine")

--

local knownMachines = {}

local function exec(partialAdress, name)
    if not knownMachines[partialAdress] then

        local address = Component.get(partialAdress)

        local machineComponent =
            (address and Component.proxy(address)) -- Exists
            or
                (findIn(Component.list(), "ocemu") and
                    mock:new(partialAdress, name)) -- Is running on emulator
            or nil

        knownMachines[partialAdress] = New(machineEntity, machineComponent,
                                           {name = name})
    end

    return knownMachines[partialAdress]
end

return exec
