-- Import section

Component = require("component")
Modem = Component.modem
Navigation = Component.navigation
Term = require("term")
Event = require("event")
Constants = {machineAddPort = 0xADD, inputTimeout = 20} -- require("configuration.constants")

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
    if waypointRelativeCoordinates then
        print(waypointRelativeCoordinates)
        Modem.send(server, portNumber, "waypoint_relative_coordinates", waypointRelativeCoordinates)
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
    Term.clear()
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
        for _, v in ipairs({...}) do
            print(v)
        end
        local args = {...}
        if port == portNumber and args[1] == "what_are_the_waypoint_relative_coordinates" then
            getWaypointRelativeCoordinates(sender)
        end
    end
)

Event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_are_your_coordinates" then
            getMyCoordinates(sender)
        end
    end
)

Event.listen(
    "modem_message",
    function(_evName, _tabletAddress, sender, port, _distance, ...)
        local args = {...}
        if port == portNumber and args[1] == "what_is_the_machine_name" then
            getMachineName(sender)
        end
    end
)
