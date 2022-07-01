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
    local function waypointDataListener(_, _, _, port, _, messageName, arg)
        if port == portNumber and messageName == "waypoint_data" then
            local waypointData = serialization.unserialize(arg) or {}
            knownMachines[machineAddress] = {
                name = waypointData[1] or machineAddress,
                redstone = waypointData[2],
                location = {waypointData[3], waypointData[4], waypointData[5]}
            }
        end
    end

    event.listen("modem_message", waypointDataListener)

    event.timer(
        responseTime,
        function()
            event.ignore("modem_message", waypointDataListener)
            knownMachines[machineAddress] = knownMachines[machineAddress] or {name = machineAddress, location = {}}
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
    local waypointAddress = componentAddresses["waypoint"] or " "
    if machineAddress then
        local waypointLabel = component.get(waypointAddress) and component.proxy(waypointAddress).getLabel()
        registerWaypointDataListener(machineAddress)
        -- TODO: Add a timer for allowing the user to put a label on the waypoint
        -- User should be allowed to name the waypoint even if it has been placed after the machine
        modem.broadcast(portNumber, "what_is_the_waypoint_data", serialization.serialize(waypointLabel))

        -- Forgets the machine and the waypoint after the setup
        componentAddresses = {}
    end
end

return exec
