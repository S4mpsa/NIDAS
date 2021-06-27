-- Import section

Event = require("event")

local addressesConfigFile = "server.configuration.addresses"
local addresses = require(addressesConfigFile)
local addMachine = require("server.usecases.add-machine")
local getMultiblockStatus = require("server.usecases.get-multiblock-status")

--

local machineList = addresses
local function addToMachineList(_, address, _)
    local comp = Component.proxy(address)
    if comp.type == "waypoint" or comp.type == "gt_machine" or comp.type == "gt_batterybuffer" then
        machineList = addMachine(address, addressesConfigFile)
    end
end
Event.listen("component_added", addToMachineList)

local statuses = {}
while true do
    for address, name in pairs(machineList) do
        statuses[address] = getMultiblockStatus(address, name)
    end
    os.sleep(0)
end
