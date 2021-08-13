-- Import section

local filesystem = require("filesystem")
local event = require("event")
local component = require("component")
local modem = component.modem
local constants = require("configuration.constants")
local serialization = require("serialization")

--

local componentAddresses = {}

local addressesConfigFile = ""
local knownMachines = {}

local inputTimeout = constants.tabletInputTimeout
local tabletResponseTime = constants.tabletResponseTime

local relativeCoordinates = {math.huge, math.huge, math.huge}
local tabletAddress = ""

local portNumber = constants.machineAddPort
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
    local filePath = package.searchpath(addressesConfigFile, package.path)
    filesystem.remove(filePath)
    local configFile = io.open(filePath, "w")
    configFile:write("local addresses =\n")

    configFile:write(serialization.serialize(knownMachines, true))

    configFile:write("\n\n")
    configFile:write("return addresses\n")
    configFile:close()

    reloadAddressesConfigFile()
end

local function registerMachineNameListener(machineAddress)
    knownMachines[machineAddress].name = "Unknown"
    local function machineNameListener(_evName, _serverAddress, sender, port, _distance, ...)
        local args = {...}
        if sender == tabletAddress and port == portNumber and args[1] == "machine_name" then
            local name = serialization.unserialize(args[2])
            knownMachines[machineAddress].name = name
        end
    end

    event.listen("modem_message", machineNameListener)

    event.timer(
        inputTimeout,
        function()
            event.ignore("modem_message", machineNameListener)
            rewriteAddressFile()
            tabletAddress = ""
        end
    )
end

local function registerTabletCoordinatesListener(machineAddress)
    local function tabletCoordinatesListener(_evName, _serverAddress, sender, port, _distance, ...)
        local args = {...}
        if sender == tabletAddress and port == portNumber and args[1] == "my_coordinates" then
            local tabletCoordinates = serialization.unserialize(args[2])
            knownMachines[machineAddress].coordinates = {
                math.floor(tabletCoordinates[1] + relativeCoordinates[1]),
                math.floor(tabletCoordinates[2] + relativeCoordinates[2]),
                math.floor(tabletCoordinates[3] + relativeCoordinates[3])
            }
        end
    end

    event.listen("modem_message", tabletCoordinatesListener)

    event.timer(
        tabletResponseTime,
        function()
            event.ignore("modem_message", tabletCoordinatesListener)
            rewriteAddressFile()
            relativeCoordinates = {math.huge, math.huge, math.huge}
        end
    )
end

local function registerWaypointRelativeCoordinatesListener()
    local minDistance = math.huge
    local function relativeCoordinatesListener(_evName, _serverAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "waypoint_relative_coordinates" then
            local senderRelativeCoordinates = serialization.unserialize(args[2])
            local senderDistance =
                senderRelativeCoordinates[1] ^ 2 + senderRelativeCoordinates[2] ^ 2 + senderRelativeCoordinates[3] ^ 2
            if minDistance > senderDistance then
                tabletAddress = sender
                minDistance = senderDistance
                relativeCoordinates = senderRelativeCoordinates
            end
        end
    end

    event.listen("modem_message", relativeCoordinatesListener)

    event.timer(
        tabletResponseTime,
        function()
            event.ignore("modem_message", relativeCoordinatesListener)
        end
    )
end

-- Pings tablets for information about the newly placed machine and waypoint
-- and registers listeners for machine setup
local function pingTablets(waypointAddress, machineAddress)
    modem.broadcast(portNumber, "wakeup_tablet")
    event.timer(
        constants.tabletBootUpTime,
        function()
            registerWaypointRelativeCoordinatesListener()
            modem.broadcast(portNumber, "what_are_the_waypoint_relative_coordinates", waypointAddress)
            event.timer(
                tabletResponseTime,
                function()
                    registerTabletCoordinatesListener(machineAddress)
                    modem.broadcast(portNumber, "what_are_your_coordinates")
                    event.timer(
                        tabletResponseTime,
                        function()
                            registerMachineNameListener(machineAddress)
                            modem.broadcast(portNumber, "what_is_the_machine_name")
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

    local comp = component.proxy(address)
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
