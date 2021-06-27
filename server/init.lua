-- Import section

Event = require("event")

local addressesConfigFile = "configuration.addresses"
local addresses = require(addressesConfigFile)
local addMachine = require("server.usecases.add-machine")
local getMultiblockStatus = require("server.usecases.get-multiblock-status")

--

local function updateMachineList(_, address, _)
    local comp = Component.proxy(address)
    if comp.type == "waypoint" or comp.type == "gt_machine" or comp.type == "gt_batterybuffer" then
        addMachine(address, addressesConfigFile)
    end
end
Event.listen("component_added", updateMachineList)

local statuses = {}
while true do
    for address, name in pairs(addresses) do
        statuses[address] = getMultiblockStatus(address, name)
    end
    os.sleep(0)
end
