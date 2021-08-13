-- Import section
Event = require("event")

local addressesConfigFile = "settings.machine-addresses"
local machineAddresses = require(addressesConfigFile)
local powerAddress = require("settings.power-address")
local addMachine = require("server.usecases.add-machine")
local getMultiblockStatus = require("server.usecases.get-multiblock-status")
local getPowerStatus = require("server.usecases.get-lsc-status")

--

local server = {}

local function updateMachineList(_, address, _)
    local comp = Component.proxy(address)
    if comp.type == "waypoint" or comp.type == "gt_machine" or comp.type == "gt_batterybuffer" then
        addMachine(address, addressesConfigFile)
    end
end
Event.listen("component_added", updateMachineList)

local statuses = {multiblocks = {}, power = {}}

function server.configure(x, y)
    -- TODO: Code for GUI configuration of machines:
    ---- Machine renaming
    ---- Machine widgets layout
end

function server.update()
    for address, name in pairs(machineAddresses) do
        statuses.multiblocks[address] = getMultiblockStatus(address, name)
    end
    statuses.power = getPowerStatus(powerAddress, "Lapotronic Supercapacitor")
    return statuses
end

return server
