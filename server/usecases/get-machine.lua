-- Import section

Component = require("component")
Filesystem = require("filesystem")

local findIn = require("utils.find-in")
local mock = require("server.entities.mocks.mock-machine")
local machineEntity = require("server.entities.machine")

--

local function exec(partialAdress, name)
    local machine = nil

    local successful =
        pcall(
        function()
            machine = New(machineEntity, Component.proxy(Component.get(partialAdress)), {name = name})
        end
    )
    if not successful then
        if findIn(Component.list(), "ocemu") then -- Is running on emulator
            machine = New(machineEntity, mock:new(partialAdress, name))
        else
            machine = New(machineEntity)
        end
    end

    return machine
end

return exec
