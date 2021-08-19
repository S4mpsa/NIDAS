-- Import section

local event = require("event")
local serialization = require("serialization")
local term = require("term")
local component = require("component")
local modem = component.modem

local portNumber = require("configuration.constants").machineAddPort

--

local droneData = {}

local function save()
    local file = io.open("/home/NIDAS/settings/droneData", "w")
    file:write(serialization.serialize(droneData))
    file:close()
end

local function queryLocation()
    print("Drone location not set.")
    term.write("Insert X coordinate: ")
    local x = tonumber(term.read(_, true))
    term.write("Insert Y coordinate: ")
    local y = tonumber(term.read(_, true))
    term.write("Insert Z coordinate: ")
    local z = tonumber(term.read(_, true))
    droneData.coordinates = {x = x, y = y, z = z}
    save()
end

local function load()
    local file = io.open("/home/NIDAS/settings/droneData", "r")
    if file then
        droneData = serialization.unserialize(file:read("*a"))
        if droneData and droneData.droneLocation then
            local x, y, z = component.navigation.getPosition()
            if x == nil then
                error("The drone is out of range of the map.")
            end
            if droneData.droneLocation[1] ~= x or droneData.droneLocation[2] ~= y or droneData.droneLocation[3] ~= z then
                droneData.droneLocation = {x, y, z}
                queryLocation()
            end
        end
        file:close()
    else
        local x, y, z = component.navigation.getPosition()
        if x == nil then
            error("The drone is out of range of the map.")
        end
        droneData.droneLocation = {x, y, z}
        queryLocation()
    end
end
load()
modem.open(portNumber)

local function getWaypointData(label)
    local waypoints = component.navigation.findWaypoints(512)
    local waypoint

    local chancesToBeIt = 0
    local previousChances = 0
    for _, wp in ipairs(waypoints) do
        if wp.redstone > 0 then
            -- Waypoint with a redstone signal
            chancesToBeIt = chancesToBeIt + 1
        end
        if #wp.label > 0 then
            -- Waypoint with a label
            chancesToBeIt = chancesToBeIt + 1
            if wp.label == label then
                -- Waypoint with the correct label
                chancesToBeIt = chancesToBeIt + 2
            end
        end
        if chancesToBeIt > previousChances then
            waypoint = wp
            previousChances = chancesToBeIt
        end
        if previousChances == 4 then
            break
        end
        chancesToBeIt = 0
    end

    if waypoint then
        local waypointData = {
            waypoint.label,
            waypoint.redstone,
            droneData.coordinates.x + waypoint.position[1],
            droneData.coordinates.y + waypoint.position[2],
            droneData.coordinates.z + waypoint.position[3]
        }
        return waypointData
    else
        -- No waypoints within range
        return nil
    end
end

local function sendWaypointData(_, _, senderAddress, port, _, messageName, label)
    if port == portNumber and messageName == "what_is_the_wapoint_data" then
        print("Sending coordinate data for waypoint labeled " .. serialization.unserialize(label))
        modem.send(senderAddress, portNumber, "waypoint_data", serialization.serialize(getWaypointData(label)))
    end
end
event.listen("modem_message", sendWaypointData)
