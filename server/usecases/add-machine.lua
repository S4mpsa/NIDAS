-- Import section

Component = require("component")
Event = require("event")

--

local componentAddresses = {}

local addressesConfigFile = ""
local knownMachines = {}

local inputTimeout = 20
local noInputTimeout = 2

local relativeCoordinates = {}
local tabletAddress = ""

local portNumber = 0xADD
local modem = Component.modem
modem.open(portNumber)

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
        configFile:write("            x = " .. properties.coordinates.x .. ",")
        configFile:write("            y = " .. properties.coordinates.y .. ",")
        configFile:write("            z = " .. properties.coordinates.z)
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
        function(_, sender, port, _, ...)
            if sender == tabletAddress and port == portNumber and arg[1] == "machine_name" then
                local name = arg[2]
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
        function(_, sender, port, _, ...)
            if sender == tabletAddress and port == portNumber and arg[1] == "my_coordinates" then
                local tabletCoordinates = arg[2]
                knownMachines[machineAddress].coordinates = {
                    x = math.floor(tabletCoordinates.x + relativeCoordinates.x),
                    y = math.floor(tabletCoordinates.y + relativeCoordinates.y),
                    z = math.floor(tabletCoordinates.z + relativeCoordinates.z)
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
        function(_, sender, port, _, ...)
            if port == portNumber and arg[1] == "waypoint_relative_coordinates" then
                local senderRelativeCoordinates = arg[2]
                local senderDistance =
                    senderRelativeCoordinates.x ^ 2 + senderRelativeCoordinates.y ^ 2 + senderRelativeCoordinates.z ^ 2
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

    modem.broadcast(portNumber, "what_are_the_waypoint_relative_coordinates", waypointAddress)
    modem.send(tabletAddress, portNumber, "what_are_your_coordinates")
    modem.send(tabletAddress, portNumber, "what_is_the_machine_name")

    return {name = nil, coordinates = {}}
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

    return knownMachines
end

return exec
