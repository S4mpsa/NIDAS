local component = require("component")
local node = require("core.network.node")
local message = require("core.lib.message")
local stringUtils = require("core.lib.stringUtils")
local nodeManager = {}

local function sendMessage(destination, ...)

end

function nodeManager.init()
    if component.modem then
        node.start()
    end
end

function nodeManager.openStream(path, machineAddress)
    local paths = stringUtils.split(path, ",")
    if #paths > 1 then --Need to ask for a relayed message
        
    elseif #paths == 1 then --Can query directly
        local source = paths[1]
        node.send(path, message.openStream, machineAddress)
    end
end

--Sends a message to close an opened stream to another node
function node.closeStream(address)

end

---Sends a new machine to all other nodes
---@param source string
---@param machineAddress string
---@param machineData table
function nodeManager.broadcastMachine(source, machineAddress, machineData)
    node.broadcast(message.addMachine, {source=source, address=machineAddress, data=machineData})
end

return nodeManager