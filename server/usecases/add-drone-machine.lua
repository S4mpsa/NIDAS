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

local responseTime = constants.networkResponseTime

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
    pcall(
        function()
            knownMachines = require(addressesConfigFile)
        end
    )
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

local function registerWaypointDataListener(machineAddress)
    knownMachines[machineAddress].name = "Unknown"
    local function waypointDataListener(_, _, _, port, _, messageName, arg)
        if port == portNumber and messageName == "waypoint_data" then
            local waypointData = serialization.unserialize(arg)
            knownMachines[machineAddress] = {
                location = {waypointData[1], waypointData[2], waypointData[3]},
                label = waypointData[4],
                redstone = waypointData[5]
            }
        end
    end

    event.listen("modem_message", waypointDataListener)

    event.timer(
        responseTime,
        function()
            event.ignore("modem_message", waypointDataListener)
            rewriteAddressFile()
        end
    )
end

local function exec(address, packageName, label)
    addressesConfigFile = packageName
    reloadAddressesConfigFile()
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
