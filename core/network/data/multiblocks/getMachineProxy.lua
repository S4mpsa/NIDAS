local component = require("component")
local event = require("event")
local serialization = require("serialization")
local ebf = require("core.network.data.multiblocks.electricBlastFurnace")
local lsc = require("core.network.data.multiblocks.supercapacitor")
local pa = require("core.network.data.multiblocks.processingArray")
local message = require("core.lib.message")
local gtTypeTable = {
    ["multimachine.supercapacitor"] = lsc,
    ["multimachine.blastfurnace"] = ebf,
    ["multimachine.processingarray"] = pa
}


local function getProxy(address, source)
    --GT Machines
    if source == "local" then
        if component.proxy(address) then
            local proxy = component.proxy(address)
            if proxy.type == "gt_machine" then
                if proxy.getName() then
                    if gtTypeTable[proxy.getName()] then
                        return gtTypeTable[proxy.getName()](proxy)
                    end
                end
            end
        end
    else --Establish a remote proxy over network
        local remoteProxy = gtTypeTable[componentManager.list()[address].machineType](nil)
        local i = 0
        local function updateFromPacket(_, remoteAddress, dataPacket)
            log("Received update packet: " .. tostring(i))
            i = i + 1
            if remoteAddress == address then
                event.push("update_received", address)
                for variable, value in pairs(serialization.unserialize(dataPacket)) do
                    if value then
                        remoteProxy[variable] = value
                    end
                end
            end
        end
        componentManager.addStream(address, updateFromPacket)
        nodeManager.openStream(componentManager.list()[address].source, address)
        event.listen(message.dataPacket, updateFromPacket)
        return remoteProxy
    end
    return nil
end



return getProxy