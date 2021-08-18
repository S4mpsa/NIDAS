-- Import section

local event = require("event")
local serialization = require("serialization")

local component = require("component")
local modem = component.modem

local constants = require("configuration.constants")

--

local componentAddresses = {}

local knownMachines = {}

local responseTime = constants.networkResponseTime

local portNumber = constants.machineAddPort
modem.open(portNumber)

local function save()
    local file = io.open("/home/NIDAS/settings/known-machines", "w")
    file:write(serialization.serialize(knownMachines))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/known-machines", "r")
    if file then
        knownMachines = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
end
load()

local function registerWaypointDataListener(machineAddress)
    knownMachines[machineAddress].name = "Unknown"
    local function waypointDataListener(_, _, _, port, _, messageName, arg)
        if port == portNumber and messageName == "waypoint_data" then
            local waypointData = serialization.unserialize(arg)
            knownMachines[machineAddress] = {
                location = {waypointData[1], waypointData[2], waypointData[3]},
                name = waypointData[4],
                redstone = waypointData[5]
            }
        end
    end

    event.listen("modem_message", waypointDataListener)

    event.timer(
        responseTime,
        function()
            event.ignore("modem_message", waypointDataListener)
            save()
            load()
        end
    )
end

local function exec(address)
    load()
    -- Skips machine setup if it's already in the configuration file
    if knownMachines[address] then
        return
    end

    local proxy = component.proxy(address)
    componentAddresses[proxy.type] = address

    local machineAddress = componentAddresses["gt_machine"] or componentAddresses["gt_batterybuffer"]
    if machineAddress and componentAddresses["waypoint"] then
        local waypoint = component.proxy(componentAddresses["waypoint"])
        knownMachines[machineAddress] = {}
        registerWaypointDataListener(machineAddress)
        -- TODO: Add a timer for allowing the user to put a label on the waypoint
        -- User should be allowed to name the waypoint even if it has been placed after the machine
        modem.broadcast(portNumber, "what_is_the_wapoint_data", serialization.serialize(waypoint.getLabel()))

        -- Forgets the machine after it's been set up
        componentAddresses["gt_machine"] = nil
        componentAddresses["gt_batterybuffer"] = nil
    end
end

return exec
