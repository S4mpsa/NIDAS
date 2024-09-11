local event = require("event")
local component = require("component")
local data = require("core.lib.data")
local message = require("core.lib.message")

local componentManager = {}

local machineDataFile = "knownAddresses"
local addressList = {}
local streamList = {}

function componentManager.list()
    return addressList
end

function componentManager.addStream(address, listener)
    streamList[address] = listener
end

function componentManager.closeStream(address)
    nodeManager.closeStream(address)
    event.ignore(message.dataPacket, streamList[address])
end

function componentManager.addRemoteMachine(machineData)
    if not addressList[machineData.address] then
        addressList[machineData.address] = machineData.data
        addressList[machineData.address].source = machineData.source
        data.save(machineDataFile, addressList)
    end
end

local function addExistingMachines()
    local changes = false
    for address, _ in pairs(component.list("gt_machine")) do
        if not addressList[address] then
            changes = true
            local localProxy = component.proxy(address)
            local x, y, z = localProxy.getCoordinates()
            addressList[address] = {type = "gt_machine", machineType = localProxy.getName(), location = {x = x, y = y, z = z}, source="local"}
            if component.modem then
                nodeManager.broadcastMachine(component.modem.address, address, addressList[address])
            end
        end
    end
    if changes then data.save(machineDataFile, addressList) end
end

local function processLocalChange(eventName, address, type)
    if eventName == "component_added" then
        if type == "gt_machine" then
            local localProxy = component.proxy(address)
            local x, y, z = localProxy.proxy.getCoordinates()
            addressList[address] = {type = "gt_machine", machineType = localProxy.getName(), location = {x = x, y = y, z = z}, source="local"}
            if component.modem then
                nodeManager.broadcastMachine(component.modem.address, address, addressList[address])
            end
            data.save(machineDataFile, addressList)
        end
    elseif eventName == "component_removed" then
        if addressList[address] then
            addressList[address] = nil
            data.save(machineDataFile, addressList)
        end
    end
end

local function processRemoteChange()

end

function componentManager.init()
    addressList = data.load(machineDataFile) or {}
    addExistingMachines()
    event.listen("component_added", processLocalChange)
    event.listen("component_removed", processLocalChange)
end

return componentManager