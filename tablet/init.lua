-- Import section

local component = require("component")
local modem = component.modem
local navigation = component.navigation
local term = require("term")
local event = require("event")
local constants = require("configuration.constants")

--

modem.setWakeMessage("wakeup_tablet")

local portNumber = constants.machineAddPort
modem.open(portNumber)

local function getWaypointRelativeCoordinates(server, waypointAddress)
    local waypointRelativeCoordinates = nil
    local waypoints = navigation.findWaypoints(20)
    for _, waypoint in ipairs(waypoints) do
        if waypoint.address == waypointAddress then
            waypointRelativeCoordinates = waypoint.position
        end
    end
    waypointRelativeCoordinates = waypoints[1].position
    if waypointRelativeCoordinates then
        modem.send(
            server,
            portNumber,
            "waypoint_relative_coordinates",
            waypointRelativeCoordinates[1],
            waypointRelativeCoordinates[2],
            waypointRelativeCoordinates[3]
        )
    end
end

local function getMyCoordinates(server)
    local myCoordinates = {navigation.getPosition()}
    modem.send(server, portNumber, "my_coordinates", myCoordinates[1], myCoordinates[2], myCoordinates[3])
end

local function getMachineName(server)
    local timeout =
        event.timer(
        constants.tabletInputTimeout,
        -- Presses ^C
        function()
            event.push("key_down", "", 13.0, 46.0)
            event.push("key_down", "", 0.0, 29.0)
            event.push("key_up", "", 13.0, 46.0)
            event.push("key_up", "", 0.0, 29.0)
        end
    )
    print("Please enter a name for the machine")
    print("PS: If you take longer then " .. constants.tabletInputTimeout .. ' seconds, machine will be named "Unknown"')
    local name = io.read()
    if name then
        event.cancel(timeout)
        modem.send(server, portNumber, "machine_name", name)
        term.clear()
    end
end

event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_are_the_waypoint_relative_coordinates" then
            getWaypointRelativeCoordinates(sender, args[2])
        end
    end
)

event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_are_your_coordinates" then
            getMyCoordinates(sender)
        end
    end
)

event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_is_the_machine_name" then
            getMachineName(sender)
        end
    end
)
