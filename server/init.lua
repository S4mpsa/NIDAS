-- Import section

local event = require("event")
local component = require("component")
local modem = component.modem
local serialization = require("serialization")

local getMultiblockStatus = require("server.usecases.get-multiblock-status")
local getPowerStatus = require("server.usecases.get-lsc-status")

local constants = require("configuration.constants")
local portNumber = constants.machineStatusPort

local namespace = {
    serverData = {},
    knownMachines = {},
    statuses = {multiblocks = {}, power = {}}
}
local server = {}

--

function namespace.save()
    local file = io.open("/home/NIDAS/settings/serverData", "w")
    file:write(serialization.serialize(namespace.serverData))
    file:close()
    file = io.open("/home/NIDAS/settings/machineData", "w")
    file:write(serialization.serialize(namespace.statuses))
    file:close()
    file = io.open("/home/NIDAS/settings/known-machines", "w")
    file:write(serialization.serialize(namespace.knownMachines))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/serverData", "r")
    if file then
        namespace.serverData = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
    file = io.open("/home/NIDAS/settings/machineData", "r")
    if file then
        namespace.statuses = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
    file = io.open("/home/NIDAS/settings/known-machines", "r")
    if file then
        namespace.knownMachines = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
end
load()

--Sets up the event listeners for the server
require("server.event-listen")(namespace)

-- Sets up configuration menu for the server
local configure = require("server.configure")(namespace)
function server.configure(x, y, _, _, _, page)
    return configure(x, y, page)
end

local savingInterval = 500
local savingCounter = savingInterval
function server.update()
    local shouldBroadcastStatuses = false
    local statusesToBroadcast = {}

    for address, machine in pairs(namespace.knownMachines or {}) do
        local multiblockStatus = getMultiblockStatus(address, machine.name, machine.location)
        namespace.statuses.multiblocks[address] = namespace.statuses.multiblocks[address] or {}

        if  multiblockStatus.state ~= namespace.statuses.multiblocks[address].state then
            shouldBroadcastStatuses = true
            statusesToBroadcast[address] = {
                state = multiblockStatus.state,
                problems = multiblockStatus.problems,
                name = machine.name,
                location = machine.location
            }
        end

        namespace.statuses.multiblocks[address] = multiblockStatus
    end
    if shouldBroadcastStatuses then
        if namespace.serverData.isMain then
            event.push("notification", serialization.serialize(statusesToBroadcast))
        else
            modem.broadcast(portNumber, "local_multiblock_statuses", serialization.serialize(statusesToBroadcast))
        end
    end

    if namespace.serverData.powerAddress then
        local powerStatus = getPowerStatus(namespace.serverData.powerAddress, "Lapotronic Supercapacitor")
        if namespace.statuses.power ~= powerStatus then
            modem.broadcast(portNumber, "local_power_status", serialization.serialize(powerStatus))
        end
        namespace.statuses.power = powerStatus
    else
        namespace.statuses.power = nil
    end
    if savingCounter == savingInterval then
        namespace.save()
        savingCounter = 1
    end
    savingCounter = savingCounter + 1
    return namespace.statuses
end

return server
