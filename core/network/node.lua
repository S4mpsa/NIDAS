local event = require("event")
local component = require("component")
local serialization = require("serialization")
local message = require("core.lib.message")
local machineProxy = require("core.network.data.multiblocks.getMachineProxy")
local node = {}

local modem = nil
local messageArray = {}
local queueSize = 10
local messageCounter = 1

local function randPacket() --Taken from Minitel
    local npID = ""
    for i = 1, 16 do
        npID = npID .. string.char(math.random(32,126))
    end
    return npID
end

local function messageSeen(id)
    for i = 1, queueSize, 1 do
        if messageArray[i] == id then
            return true
        end
    end
    return false
end

--Packet structure:
--packetID: A randomized string so the same message is not processed twice
--messageType: messageType of the message, from message.lua
--destination: Detination address, relay if needed
--sender: The address of the sending modem
--data: A serialized table of the required data
local function processPacket(_, receiver, from, port, _, packetID, messageType, destination, sender, data)
    --Add new message messageType handling here
    --Data includes a serialized table with the required information
    if not messageSeen(packetID) then
        if destination ~= "~" then --Directed messages
            if receiver == destination then --Handle internally
                if messageType == message.openStream then
                    local address = serialization.unserialize(data)
                    if component.proxy(address) then
                        local proxy = machineProxy(address, "local")
                        local function sendUpdatedProxy()
                            if proxy then
                                proxy.update()
                                local dataTable = {}
                                for k,v in pairs(proxy) do
                                    if type(v) ~= "function" and k ~= "proxy" then
                                        dataTable[k] = v
                                    end
                                end
                                node.send(sender, message.dataPacket, {address=address, dataTable=dataTable})
                            end
                        end
                        moduleManager.addPeriodic(address, sendUpdatedProxy, 4)
                    end
                elseif messageType == message.closeStream then
                    local address = serialization.unserialize(data)
                    if moduleManager.listPeriodic()[address] then
                        moduleManager.removePeriodic(address)
                    end
                elseif messageType == message.dataPacket then
                    local receivedData = serialization.unserialize(data)
                    if receivedData then
                        event.push(message.dataPacket, receivedData.address, serialization.serialize(receivedData.dataTable))
                    end
                end
            else  --Relay?

            end
        else --Broadcasted messages
            if messageType == "request" then
                
            elseif messageType == "cancel" then

            elseif messageType == message.addMachine then
                helper = serialization.unserialize(data)
                componentManager.addRemoteMachine(serialization.unserialize(data))
            end
        end
    end
    messageArray[messageCounter] = packetID
    messageCounter = (messageCounter + 1) % queueSize
end


function node.send(destination, messageType, data)
    modem.send(destination, settings.nidasPort, randPacket(), messageType, destination, modem.address, serialization.serialize(data))
end
---Broadcasts a data table to all nodes in the network.
---Data table must not contain functions.
---@param data any
function node.broadcast(messageType, data)
    if modem then
        modem.broadcast(settings.nidasPort, randPacket(), messageType, "~", modem.address, serialization.serialize(data))
    end
end

--Starts the message handlers for modem messages
function node.start()
    event.listen("modem_message", processPacket)
    if component.modem then
        modem = component.modem
        modem.open(settings.nidasPort)
    end
end


return node
