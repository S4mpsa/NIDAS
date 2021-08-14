-- Import section
local event = require("event")
local component = require("component")
local modem = component.modem
local serialization = require("serialization")

local addressesConfigFile = "settings.machine-addresses"
local machineAddresses = require(addressesConfigFile)
local powerAddress = require("settings.power-address")
local addMachine = require("server.usecases.add-machine")
local getMultiblockStatus = require("server.usecases.get-multiblock-status")
local getPowerStatus = require("server.usecases.get-lsc-status")

local constants = require("configuration.constants")
local portNumber = constants.machineStatusPort
local serverResponseTime = constants.networkResponseTime

local serverData = {}
local server = {}
local statuses = {multiblocks = {}, power = {}}

--

local function save()
    serverData.statuses = statuses
    local file = io.open("/home/NIDAS/settings/serverData", "w")
    file:write(serialization.serialize(serverData))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/serverData", "r")
    if file then
        serverData = serialization.unserialize(file:read("*a")) or {statuses = statuses}
        statuses = serverData.statuses
        file:close()
    end
end
load()

local function updateMachineList(_, address, _)
    local comp = component.proxy(address)
    if comp.type == "waypoint" or comp.type == "gt_machine" or comp.type == "gt_batterybuffer" then
        addMachine(address, addressesConfigFile)
    end
end
event.listen("component_added", updateMachineList)

if serverData.isMain == nil then
    -- Server not configured yet
    local function filter(eventName, ...)
        local signalParams = {...}
        local port = signalParams[4]
        local args = signalParams[6]
        return eventName == "modem_message" and port == portNumber and args and args[1] == "I_am_the_main_server"
    end

    modem.broadcast(portNumber, "are_you_the_main_server")

    local response = event.pullFiltered(serverResponseTime, filter)
    if response == nil then
        -- There's no other main server
        serverData.isMain = true
        local function identifyAsMainServer(_evName, _localAddress, sender, port, _distance, ...)
            local args = {...}
            if port == portNumber and args[1] == "are_you_the_main_server" then
                modem.send(sender, portNumber, "I_am_the_main_server")
            end
        end
        event.listen("modem_message", identifyAsMainServer)
    end
    save()
end

if serverData.isMain then
    modem.broadcast(portNumber, "get_status")
end

local function sendStatuses(_evName, _localAddress, sender, port, _distance, ...)
    local args = {...}
    if port == portNumber and args[1] == "get_status" then
        local updatedStatuses = {}
        for address, status in statuses.multiblocks do
            updatedStatuses[address] = {state = status.state, problems = status.problems}
        end
        modem.send(sender, portNumber, "local_multiblock_statuses", serialization.serialize(updatedStatuses))
    end
end
if not serverData.isMain then
    event.listen("modem_message", sendStatuses)
end

local function updateMachineStatuses(_, _, _, port, _, ...)
    local args = {...}
    if port == portNumber and args[1] == "local_multiblock_statuses" then
        for address, status in pairs(serialization.unserialize(args[2])) do
            statuses.multiblocks[address] = status
        end
    end
end
if serverData.isMain then
    event.listen("modem_message", updateMachineStatuses)
end

local function updatePowerStatus(_, _, _, port, _, ...)
    local args = {...}
    if port == portNumber and args[1] == "local_power_status" then
        statuses.powerStatus = serialization.unserialize(args[2])
    end
end
event.listen("modem_message", updatePowerStatus)

function server.configure(x, y)
    -- TODO: Code for GUI configuration of server:
    ---- Machine renaming
    ---- Machine widgets layout?
    ---- Selecting server type: main or local
end

-- TODO: Persist to file
local savingInterval = 500
local savingCounter = savingInterval
function server.update()
    local shouldBroadcastStatuses = false
    local updatedStatuses = {}

    for address, name in pairs(machineAddresses or {}) do
        local multiblockStatus = getMultiblockStatus(address, name)
        statuses.multiblocks[address] = statuses.multiblocks[address] or {}

        if multiblockStatus.state ~= statuses.multiblocks[address].state then
            shouldBroadcastStatuses = shouldBroadcastStatuses or not serverData.isMain
            updatedStatuses[address] = {state = multiblockStatus.state, problems = multiblockStatus.problems}
        end

        statuses.multiblocks[address] = multiblockStatus
    end

    if shouldBroadcastStatuses then
        modem.broadcast(portNumber, "local_multiblock_statuses", serialization.serialize(updatedStatuses))
    end

    if powerAddress then
        local powerStatus = getPowerStatus(powerAddress, "Lapotronic Supercapacitor")
        if statuses.powerStatus ~= powerStatus then
            modem.broadcast(portNumber, "local_power_status", serialization.serialize(powerStatus))
        end
        statuses.powerStatus = powerStatus
    end
    if savingCounter == savingInterval then
        save()
        savingCounter = 1
    end
    savingCounter = savingCounter + 1
    return statuses
end

return server
