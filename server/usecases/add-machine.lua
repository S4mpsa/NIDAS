-- Import section

Filesystem = require("filesystem")
Event = require("event")
Component = require("component")
Modem = Component.modem
Constants = {
    inputTimeout = 10,
    tabletBootUpTime = 3,
    machineAddPort = 0xADD,
    tabletResponseTime = 3
} --require("configuration.constants")

--

local componentAddresses = {}

local addressesConfigFile = ""
local knownMachines = {}

local inputTimeout = Constants.inputTimeout
local tabletResponseTime = Constants.tabletResponseTime

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
    local filePath = package.searchpath(addressesConfigFile, package.path)
    print("rewriting " .. filePath .. "...")
    Filesystem.remove(filePath)
    local configFile = io.open(filePath, "w")
    configFile:write("local addresses = {\n")
    for address, properties in knownMachines do
        configFile:write('    ["' .. address .. '"] = {\n')
        configFile:write("        name = " .. properties.name .. ",\n")
        configFile:write("        coordinates = {\n")
        configFile:write("            " .. properties.coordinates[1] .. ",\n")
        configFile:write("            " .. properties.coordinates[2] .. ",\n")
        configFile:write("            " .. properties.coordinates[3] .. "\n")
        configFile:write("        }\n")
        configFile:write("    },\n")
    end
    configFile:write("}\n")
    configFile:write("return addresses\n")
    configFile:close()

    reloadAddressesConfigFile()
end

local function registerMachineNameListener(machineAddress)
    knownMachines[machineAddress].name = "Unknown"
    local function machineNameListener(_evName, _serverAddress, sender, port, _distance, ...)
        local args = {...}
        if sender == tabletAddress and port == portNumber and args[1] == "machine_name" then
            local name = args[2]
            knownMachines[machineAddress].name = name
        end
    end

    Event.listen("modem_message", machineNameListener)

    Event.timer(
        inputTimeout,
        function()
            Event.ignore("modem_message", machineNameListener)
            print('Machine name: "' .. knownMachines[machineAddress].name .. '"')
            rewriteAddressFile()
            tabletAddress = ""
        end
    )
end

local function registerTabletCoordinatesListener(machineAddress)
    knownMachines[machineAddress].coordinates = {}
    local function tabletCoordinatesListener(_evName, _serverAddress, sender, port, _distance, ...)
        local args = {...}
        if sender == tabletAddress and port == portNumber and args[1] == "my_coordinates" then
            print("got tablet coordinates")
            local tabletCoordinates = args[2]
            knownMachines[machineAddress].coordinates = {
                x = math.floor(tabletCoordinates[1] + relativeCoordinates[1]),
                y = math.floor(tabletCoordinates[2] + relativeCoordinates[2]),
                z = math.floor(tabletCoordinates[3] + relativeCoordinates[3])
            }
        end
    end

    Event.listen("modem_message", tabletCoordinatesListener)

    Event.timer(
        tabletResponseTime,
        function()
            Event.ignore("modem_message", tabletCoordinatesListener)
            rewriteAddressFile()
            relativeCoordinates = {}
        end
    )
end

local function registerWaypointRelativeCoordinatesListener()
    local minDistance = math.huge
    local function relativeCoordinatesListener(_evName, _serverAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "waypoint_relative_coordinates" then
            print("got relative coordinates")
            local senderRelativeCoordinates = {args[2], args[3], args[4]}
            local senderDistance =
                senderRelativeCoordinates[1] ^ 2 + senderRelativeCoordinates[2] ^ 2 + senderRelativeCoordinates[3] ^ 2
            if minDistance > senderDistance then
                tabletAddress = sender
                minDistance = senderDistance
                relativeCoordinates = senderRelativeCoordinates
            end
        end
    end

    Event.listen("modem_message", relativeCoordinatesListener)

    Event.timer(
        tabletResponseTime,
        function()
            Event.ignore("modem_message", relativeCoordinatesListener)
        end
    )
end

-- Pings tablets for information about the newly placed machine and waypoint
-- and registers listeners for machine setup
local function pingTablets(waypointAddress, machineAddress)
    Modem.broadcast(portNumber, "wakeup_tablet")
    Event.timer(
        Constants.tabletBootUpTime,
        function()
            registerWaypointRelativeCoordinatesListener()
            Modem.broadcast(portNumber, "what_are_the_waypoint_relative_coordinates", waypointAddress)
            Event.timer(
                tabletResponseTime,
                function()
                    registerTabletCoordinatesListener(machineAddress)
                    Modem.broadcast(portNumber, "what_are_your_coordinates")
                    Event.timer(
                        tabletResponseTime,
                        function()
                            registerMachineNameListener(machineAddress)
                            Modem.broadcast(portNumber, "what_is_the_machine_name")
                        end
                    )
                end
            )
        end
    )
end

local function exec(address, packageName)
    addressesConfigFile = packageName
    reloadAddressesConfigFile()
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
