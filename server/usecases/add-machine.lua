-- Import section

Component = require("component")
Event = require("event")
Modem = Component.modem
Constants = require("configuration.constants")

--

local componentAddresses = {}

local addressesConfigFile = ""
local knownMachines = {}

local inputTimeout = Constants.inputTimeout
local noInputTimeout = Constants.noInputTimeout

local relativeCoordinates = {}
local tabletAddress = ""

local portNumber = Constants.machineAddPort
Modem.open(portNumber)

local function reloadAddressesConfigFile()
    -- Unloads the config file from memory
    pcall(
        function()
            package.loaded[addressesConfigFile] = nil
        end
    )
    -- Reloads the config file
    knownMachines = require(addressesConfigFile)
end

-- Rewrites the address configuration file, based on the knownMachines
local function rewriteAddressFile()
    local configFile = io.open(addressesConfigFile, "w")
    configFile:write("local addresses = {")
    for address, properties in knownMachines do
        configFile:write('    ["' .. address .. '"] = {')
        configFile:write("        name = " .. properties.name .. ",")
        configFile:write("        coordinates = {")
        configFile:write("            " .. properties.coordinates[1] .. ",")
        configFile:write("            " .. properties.coordinates[2] .. ",")
        configFile:write("            " .. properties.coordinates[3])
        configFile:write("        }")
        configFile:write("    },")
    end
    configFile:write("}\n")
    configFile:write("return addresses\n")
    configFile:close()

    reloadAddressesConfigFile()
end

local function registerMachineNameListener(machineAddress)
    knownMachines[machineAddress].name = "Unknown"
    local eventId =
        Event.listen(
        "modem_message",
        function(_evName, _tabletAddress, sender, port, _distance, ...)
            local args = {...}
            if sender == tabletAddress and port == portNumber and args[1] == "machine_name" then
                local name = args[2]
                knownMachines[machineAddress].name = name
            end
        end
    )

    Event.timer(
        inputTimeout,
        function()
            Event.ignore("modem_message", eventId)
            rewriteAddressFile()
            tabletAddress = ""
        end
    )
end

local function registerTabletCoordinatesListener(machineAddress)
    knownMachines[machineAddress].coordinates = {}
    local eventId =
        Event.listen(
        "modem_message",
        function(_evName, _tabletAddress, sender, port, _distance, ...)
            local args = {...}
            if sender == tabletAddress and port == portNumber and args[1] == "my_coordinates" then
                local tabletCoordinates = args[2]
                knownMachines[machineAddress].coordinates = {
                    x = math.floor(tabletCoordinates[1] + relativeCoordinates[1]),
                    y = math.floor(tabletCoordinates[2] + relativeCoordinates[2]),
                    z = math.floor(tabletCoordinates[3] + relativeCoordinates[3])
                }
            end
        end
    )

    Event.timer(
        noInputTimeout,
        function()
            Event.ignore("modem_message", eventId)
            rewriteAddressFile()
            relativeCoordinates = {}
        end
    )
end

local function registerWaypointRelativeCoordinatesListener()
    local minDistance = math.huge
    local eventId =
        Event.listen(
        "modem_message",
        function(_evName, _tabletAddress, sender, port, _distance, ...)
            local args = {...}
            if port == portNumber and args[1] == "waypoint_relative_coordinates" then
                local senderRelativeCoordinates = args[2]
                local senderDistance =
                    senderRelativeCoordinates[1] ^ 2 + senderRelativeCoordinates[2] ^ 2 +
                    senderRelativeCoordinates[3] ^ 2
                if minDistance > senderDistance then
                    tabletAddress = sender
                    minDistance = senderDistance
                    relativeCoordinates = senderRelativeCoordinates
                end
            end
        end
    )

    Event.timer(
        noInputTimeout,
        function()
            Event.ignore("modem_message", eventId)
        end
    )
end

-- Pings tablets for information about the newly placed machine and waypoint
-- and registers listeners for machine setup
local function pingTablets(waypointAddress, machineAddress)
    registerWaypointRelativeCoordinatesListener()
    registerTabletCoordinatesListener(machineAddress)
    registerMachineNameListener()

    Modem.broadcast(portNumber, "wakeup_tablet")
    Event.timer(
        Constants.tabletBootUpTime,
        function()
            Modem.broadcast(portNumber, "what_are_the_waypoint_relative_coordinates", waypointAddress)
            Event.timer(
                Constants.tabletResponseTime,
                function()
                    Modem.send(tabletAddress, portNumber, "what_are_your_coordinates", waypointAddress)
                    Modem.send(tabletAddress, portNumber, "what_is_the_machine_name")
                end
            )
        end
    )
end

local function exec(address, file)
    addressesConfigFile = file

    -- Unloads the config file from memory
    pcall(
        function()
            package.loaded[addressesConfigFile] = nil
        end
    )
    -- Reloads the config file
    knownMachines = require(addressesConfigFile)
    -- Skips machine setup if it's already in the configuration file
    if knownMachines[address] then
        return
    end

    local comp = Component.proxy(address)
    componentAddresses[comp.type] = address

    local machineAddress = componentAddresses["gt_machine"] or componentAddresses["gt_batterybuffer"]
    if machineAddress and componentAddresses["waypoint"] then
        knownMachines[machineAddress] = {}
        pingTablets(componentAddresses["waypoint"], machineAddress)

        -- Forgets the machine after it's been set up
        componentAddresses["gt_machine"] = nil
        componentAddresses["gt_batterybuffer"] = nil
    end
end

return exec
