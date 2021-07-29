-- Import section
Component = require("component")
Filesystem = require("filesystem")
New = require("utils.new")

local findIn = require("utils.find-in")
local mock = require("server.entities.mocks.mock-machine")
local machineEntity = require("server.entities.machine")

--

local knownMachines = {}

local function exec(partialAdress, name)
    if not knownMachines[partialAdress] then

        local address = Component.get(partialAdress)
        if address then
            knownMachines[partialAdress] = New(machineEntity,
                                               Component.proxy(address),
                                               {name = name})
        else
            if findIn(Component.list(), "ocemu") then -- Is running on emulator
                knownMachines[partialAdress] =
                    New(machineEntity, mock:new(partialAdress, name))
            else
                knownMachines[partialAdress] = New(machineEntity)
            end
        end
    end

    return knownMachines[partialAdress]
end

return exec
