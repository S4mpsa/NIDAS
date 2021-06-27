-- Import section

Component = require("component")

--

local addresses = {}

local function probeWaypoint(waypointAddress)
    -- TODO:
    --- Ping tablets for their locations,
    --- Compare the distances to the waypoint,
    --- Grab the waypoint location based on the tablet location,
    --- Ask the tablet for a name for the machine
    ---- Set and then unset an event listener for the response
    --- Associate the address with the name and the coordinates
    return {}
end

local function exec(address, addressesConfigFile)
    -- Unloads the config file from memory
    pcall(
        function()
            package.loaded[addressesConfigFile] = nil
        end
    )
    -- Reloads the config file
    local knownAddresses = require(addressesConfigFile)
    -- Skips machine setup if it's already in the configuration file
    if knownAddresses[address] then
        return
    end

    local comp = Component.proxy(address)
    addresses[comp.type] = address

    local machineAddress = addresses["gt_machine"] or addresses["gt_batterybuffer"]
    if machineAddress and addresses["waypoint"] then
        local coordinates = probeWaypoint(addresses["waypoint"])
        knownAddresses[machineAddress] = {name = "Unknown", coordinates = coordinates}

        -- Rewrites the address configuration file, not erasing any previous existing machine
        local configFile = io.open(addressesConfigFile, "w")
        configFile:write("local addresses = {")
        for add, properties in knownAddresses do
            configFile:write('    ["' .. add .. '"] = {')
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

        -- Forgets the machine after it's been set up
        addresses["gt_machine"] = nil
        addresses["gt_batterybuffer"] = nil
    end

    return knownAddresses
end

return exec
