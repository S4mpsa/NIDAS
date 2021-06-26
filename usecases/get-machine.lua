-- Import section

Component = require("component")
Filesystem = require("filesystem")

local mock = require("entities.mocks.mock-machine")
local machine = require("entities.machine")

--

local function exec(partialAdress, name)
    local mach = nil

    local successfull =
        pcall(
        function()
            mach = New(machine, Component.proxy(Component.get(partialAdress)))
        end
    )
    if not successfull then
        if Filesystem.exists("/home/NIDAS/.gitignore") then -- Is in a development environment
            mach = New(machine, mock:new(partialAdress, name))
        else
            mach = machine
        end
    end

    return mach
end

return exec
