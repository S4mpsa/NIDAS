-- Import section

local event = require("event")
local addRobotMachine = require("server.usecases.add-robot-machine")
local serialization = require("serialization")

local component = require("component")
local modem = component.modem

local constants = require("configuration.constants")
local portNumber = constants.machineStatusPort
local robotResponseTime = constants.networkResponseTime
local serverResponseTime = constants.networkResponseTime

--

local function listen(server)
    local function updateMachineList(_, address, _)
        local comp = component.proxy(address)
        if comp.type == "waypoint" or comp.type == "gt_machine" or comp.type == "gt_batterybuffer" then
            addRobotMachine(address)
            event.timer(
                robotResponseTime + 0.5,
                function()
                    local file = io.open("/home/NIDAS/settings/known-machines", "r")
                    if file then
                        server.knownMachines = serialization.unserialize(file:read("*a")) or {}
                        file:close()
                    end
                end
            )
        end
    end
    event.listen("component_added", updateMachineList)

    modem.open(portNumber)

    local function isMain()
        -- Identifies as main
        local function identifyAsMainServer(_, _, sender, port, _, messageName)
            if port == portNumber and messageName == "are_you_the_main_server" then
                modem.send(sender, portNumber, "I_am_the_main_server")
            end
        end
        event.listen("modem_message", identifyAsMainServer)

        -- Gets other server statuses
        local function updateMachineStatuses(_, _, _, port, _, messageName, arg)
            if port == portNumber and messageName == "local_multiblock_statuses" then
                for address, status in pairs(serialization.unserialize(arg)) do
                    server.statuses.multiblocks[address] = status
                end
            end
        end
        event.listen("modem_message", updateMachineStatuses)
        modem.broadcast(portNumber, "get_status")
    end

    if server.serverData.isMain then
        isMain()
    elseif server.serverData.isMain == nil then
        -- Server not configured yet
        -- In case there's no response, server is main
        server.serverData.isMain = true

        local function detectMainServer(_, _, _, port, _, messageName)
            if port == portNumber and messageName == "I_am_the_main_server" then
                server.serverData.isMain = false
            end
        end

        event.listen("modem_message", detectMainServer)
        modem.broadcast(portNumber, "are_you_the_main_server")

        -- Ignores response after timeout
        event.timer(
            serverResponseTime,
            function()
                event.ignore("modem_message", detectMainServer)
                if server.serverData.isMain then
                    isMain()
                end
                server.save()
            end
        )
    else
        -- Server is local
        -- Sends it's statuses
        local function sendStatuses(_, _, sender, port, _, messageName)
            if port == portNumber and messageName == "get_status" then
                local updatedStatuses = {}
                for address, status in server.statuses.multiblocks do
                    updatedStatuses[address] = {state = status.state, problems = status.problems}
                end
                modem.send(sender, portNumber, "local_multiblock_statuses", serialization.serialize(updatedStatuses))
            end
        end
        event.listen("modem_message", sendStatuses)
    end

    local function updatePowerStatus(_, _, _, port, _, messageName, arg)
        if port == portNumber and messageName == "local_power_status" then
            server.statuses.power = serialization.unserialize(arg)
        end
    end
    event.listen("modem_message", updatePowerStatus)
end

return listen
