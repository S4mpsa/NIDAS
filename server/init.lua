-- Import section
local event = require("event")
local component = require("component")
local modem = component.modem
local serialization = require("serialize")

local addressesConfigFile = "settings.machine-addresses"
local machineAddresses = require(addressesConfigFile)
local powerAddress = require("settings.power-address")
local addMachine = require("server.usecases.add-machine")
local getMultiblockStatus = require("server.usecases.get-multiblock-status")
local getPowerStatus = require("server.usecases.get-lsc-status")

local portNumber = require("configuration.constants").machineAddPort
--

local server = {}

local function updateMachineList(_, address, _)
    local comp = component.proxy(address)
    if comp.type == "waypoint" or comp.type == "gt_machine" or comp.type == "gt_batterybuffer" then
        addMachine(address, addressesConfigFile)
    end
end
event.listen("component_added", updateMachineList)

local statuses = {multiblocks = {}, power = {}}

local function updateMachineStatuses(_evName, _localAddress, sender, port, _distance, ...)
    local args = {...}
    if port == portNumber and args[1] == "local_multiblock_statuses" then
        for address, status in pairs(serialization.unserialize(args[2])) do
            statuses.multiblocks[address] = status
        end
    end
end
event.listen("modem_message", updateMachineStatuses)

local function updatePowerStatus(_evName, _localAddress, sender, port, _distance, ...)
    local args = {...}
    if port == portNumber and args[1] == "local_power_status" then
        statuses.powerStatus = serialization.unserialize(args[2])
    end
end
event.listen("modem_message", updatePowerStatus)

function server.configure(x, y)
    -- TODO: Code for GUI configuration of machines:
    ---- Machine renaming
    ---- Machine widgets layout
end

function server.load()
    -- TODO: Ping other servers for their statuses on boot up
    ---- Check if there's no response and determine if this is the main server
end

function server.update()
    local shouldBroadcastStatuses = false
    for address, name in pairs(machineAddresses) do
        local multiblockStatus = getMultiblockStatus(address, name)
        shouldBroadcastStatuses = statuses.multiblocks[address].state ~= multiblockStatus.state
        statuses.multiblocks[address] = multiblockStatus
    end
    if shouldBroadcastStatuses then
        modem.broadcast(portNumber, "local_multiblock_statuses", serialization.serialize(statuses.multiblocks))
    end

    if powerAddress then
        local powerStatus = getPowerStatus(powerAddress, "Lapotronic Supercapacitor")
        if statuses.powerStatus ~= powerStatus then
            modem.broadcast(portNumber, "local_power_status", serialization.serialize(powerStatus))
        end
    end

    return statuses
end

return server
