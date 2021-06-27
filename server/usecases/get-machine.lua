-- Import section

Component = require("component")
Filesystem = require("filesystem")

local mock = require("entities.mocks.mock-machine")
local machineEntity = require("entities.machine")

--

local function exec(partialAdress, name)
    local machine = nil

    local successfull =
        pcall(
        function()
            machine = New(machineEntity, Component.proxy(Component.get(partialAdress)), {name = name})
        end
    )
    if not successfull then
        if Filesystem.exists("/home/NIDAS/.gitignore") then -- Is in a development environment
            machine = New(machineEntity, mock:new(partialAdress, name))
        else
            machine = New(machineEntity)
        end
    end

    return machine
end

return exec
