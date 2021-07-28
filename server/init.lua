-- Import section
Event = require("event")

local addressesConfigFile = "configuration.machine-addresses"
local machineAddresses = require(addressesConfigFile)
local powerAddress = require("configuration.power-address")
local addMachine = require("usecases.add-machine")
local getMultiblockStatus = require("usecases.get-multiblock-status")
local getPowerStatus = require("usecases.get-lsc-status")

--

local server = {}

local function updateMachineList(_, address, _)
    local comp = Component.proxy(address)
    if comp.type == "waypoint" or comp.type == "gt_machine" or comp.type ==
        "gt_batterybuffer" then addMachine(address, addressesConfigFile) end
end
Event.listen("component_added", updateMachineList)

local statuses = {multiblocks = {}, power = {}}

function server.update()
    for address, name in pairs(machineAddresses) do
        statuses.multiblocks[address] = getMultiblockStatus(address, name)
    end
    statuses.power = getPowerStatus(powerAddress, "Lapotronic Supercapacitor")
    return statuses
end

return server
