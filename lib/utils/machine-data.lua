local machinePort = require("configuration.constants").machineAddPort
local event = require("event")
local serialization = require("serialization")
local component = require("component")

local function filter(eventName, _, _, port, _, type, data)
    return (eventName == "modem_message" and type == "newMachineData" and port == machinePort)
end

local function queryData()
    component.modem.open(machinePort)
    require("component").modem.broadcast(machinePort, "getCoordinates")
    local status, _, _, _, _, _, data = event.pullFiltered(10, filter)
    if status ~= nil then
        data = serialization.unserialize(data)
        if data.redstone > 0 then
            return {x = data.x, y = data.y, z = data.z, name = data.name}
        end
    end
    return nil
end

return queryData()
