-- Import section

local event = require("event")
local component = require("component")
local serialization = require("serialization")
local port = require("configuration.constants").machineAddPort
local IO = require("term")
local modem = component.modem

--

local droneData = {}

local function save()
    local file = io.open("/home/NIDAS/settings/droneData", "w")
    file:write(serialization.serialize(droneData))
    file:close()
end

local function queryLocation()
    print("Drone location not set.")
    IO.write("Insert X coordinate: ")
    local x = tonumber(IO.read(_, true))
    IO.write("Insert Y coordinate: ")
    local y = tonumber(IO.read(_, true))
    IO.write("Insert Z coordinate: ")
    local z = tonumber(IO.read(_, true))
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

local function getWaypointData()
    local waypoint = component.navigation.findWaypoints(512)[1]
    if waypoint then
        local waypointData = {
            droneData.coordinates.x + waypoint.position[1],
            droneData.coordinates.y + waypoint.position[2],
            droneData.coordinates.z + waypoint.position[3],
            waypoint.label,
            waypoint.redstone
        }
        return waypointData
    end
    return nil
end

local function sendWaypointData(_, _, senderAddress, _, _, messageName)
    if messageName == "getCoordinates" then
        print("Sending coordinate data.")
        local x, y, z, name, redstone = getWaypointData()
        modem.send(
            senderAddress,
            port,
            "newMachineData",
            serialization.serialize({x = x, y = y, z = z, name = name, redstone = redstone})
        )
    end
end

load()
modem.open(port)
event.listen("modem_message", sendWaypointData)
