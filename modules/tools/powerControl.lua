local component = require("component")
local serialization = require("serialization")
local powerControl = {}

local powerControlData = {}

local redstone = nil
local enableLevel = 0
local disableLevel = 0


local function save(data)
    local file = io.open("/home/NIDAS/settings/powerControlData", "w")
    enableLevel = tonumber(powerControlData.enableLevel)
    disableLevel = tonumber(powerControlData.disableLevel)
    if enableLevel ~= nil and disableLevel ~= nil then
        file:write(serialization.serialize(powerControlData))
        file:close()
    end
end

local function load()
    local file = io.open("/home/NIDAS/settings/powerControlData", "r")
    if file then
        powerControlData = serialization.unserialize(file:read("*a")) or {}
        if powerControlData.address then 
            redstone = component.proxy(component.get(powerControlData.address))
            enableLevel = tonumber(powerControlData.enableLevel)
            disableLevel = tonumber(powerControlData.disableLevel)
        end
        file:close()
    end
end

local function getPercentage(data)
    return data.storedEU / data.EUCapacity
end

local engaged = nil
local function disengage()
    if engaged then redstone.setOutput({0, 0, 0, 0, 0, 0}) end
    engaged = false
end
local function engage()
    if not engaged then redstone.setOutput({15, 15, 15, 15, 15, 15}) end
    engaged = true
end

local refresh = nil
local currentConfigWindow = {}
local function changeRedstone(redstoneAddress, data)
    redstone = component.proxy(component.get(redstoneAddress))
    powerControlData.address = redstoneAddress
    local x, y, gui, graphics, renderer, page = table.unpack(data)
    renderer.removeObject(currentConfigWindow)
    refresh(x, y, gui, graphics, renderer, page)
end

function powerControl.configure(x, y, gui, graphics, renderer, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.context().gpu.setActiveBuffer(page)
    graphics.text(3, 5, "Redstone I/O:")
    local onActivation = {}
    for address, componentType in component.list() do
        if componentType == "redstone" then
            local displayName = address
            table.insert(onActivation, {displayName = displayName, value = changeRedstone, args = {address, renderingData}})
        end
    end
    local _, ySize = graphics.context().gpu.getBufferSize(page)
    table.insert(currentConfigWindow, gui.smallButton(x+15, y+2, powerControlData.address or "None", gui.selectionBox, {x+16, y+2, onActivation}))
    table.insert(currentConfigWindow, gui.bigButton(x+2, y+tonumber(ySize)-4, "Save Configuration", save))
    local attributeChangeList = {
        {name = "Active Level",      attribute = "enableLevel",            type = "string",    defaultValue = "0.85"},
        {name = "Disable Level",     attribute = "disableLevel",            type = "string",    defaultValue = "0.99"},
    }
    gui.multiAttributeList(x+3, y+3, page, currentConfigWindow, attributeChangeList, powerControlData)

    renderer.update()
    return currentConfigWindow
end
refresh = powerControl.configure

load()
engaged = redstone.getOutput(0) > 0
function powerControl.update(data)
    if data ~= nil then
        local level = getPercentage(data.powerStatus)
        if level < enableLevel then
            engage()
        elseif level > disableLevel then
            disengage()
        end
    end
end

return powerControl