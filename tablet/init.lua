-- Import section

Component = require("component")
Modem = Component.modem
Navigation = Component.navigation
Term = require("term")
Event = require("event")
Constants = {machineAddPort = 0xADD, inputTimeout = 10} -- require("configuration.constants")

--

Modem.setWakeMessage("wakeup_tablet")

local portNumber = Constants.machineAddPort
Modem.open(portNumber)

local function getWaypointRelativeCoordinates(server, waypointAddress)
    local waypointRelativeCoordinates = nil
    local waypoints = Navigation.findWaypoints(20)
    for _, waypoint in ipairs(waypoints) do
        if waypoint.address == waypointAddress then
            waypointRelativeCoordinates = waypoint.position
        end
    end
    waypointRelativeCoordinates = waypoints[1].position
    if waypointRelativeCoordinates then
        Modem.send(
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
    Modem.send(server, portNumber, "my_coordinates", Navigation.getPosition())
end

local function getMachineName(server)
    local timeout =
        Event.timer(
        Constants.inputTimeout,
        -- Presses ^C
        function()
            Event.push("key_down", "", 13.0, 46.0)
            Event.push("key_down", "", 0.0, 29.0)
            Event.push("key_up", "", 13.0, 46.0)
            Event.push("key_up", "", 0.0, 29.0)
        end
    )
    print("Please enter a name for the machine")
    print("PS: If you take longer then " .. Constants.inputTimeout .. ' seconds, machine will be named "Unknown"')
    local name = io.read()
    if name then
        Event.cancel(timeout)
        Modem.send(server, portNumber, "machine_name", name)
    end
end

Event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_are_the_waypoint_relative_coordinates" then
            print(args[1])
            getWaypointRelativeCoordinates(sender, args[2])
        end
    end
)

Event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_are_your_coordinates" then
            print(args[1])
            getMyCoordinates(sender)
        end
    end
)

Event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_is_the_machine_name" then
            print(args[1])
            getMachineName(sender)
        end
    end
)
