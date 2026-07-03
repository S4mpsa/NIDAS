local component = require("component")
local serialization = require("serialization")
local states = require("server.entities.states")
local powerControl = {}

local powerControlData = {
    enableLevel = 20,  -- Default activation at 20%
    disableLevel = 80,  -- Default deactivation at 80%
    signalType = "active_low",
    address = "None"
}

local redstone = nil
local checkingInterval = 60  
local counter = checkingInterval

local function save()
    local file = io.open("/home/NIDAS/settings/powerControlData", "w")
    if not file then return end
    
    powerControlData.enableLevel = math.min(math.max(tonumber(powerControlData.enableLevel) or 20, 0), 100)
    powerControlData.disableLevel = math.min(math.max(tonumber(powerControlData.disableLevel) or 80, 0), 100)
    
    if powerControlData.enableLevel >= powerControlData.disableLevel then
        powerControlData.enableLevel, powerControlData.disableLevel = 20, 80
    end

    file:write(serialization.serialize(powerControlData))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/powerControlData", "r")
    if file then
        local data = serialization.unserialize(file:read("*a")) or {}
        file:close()
        
        powerControlData = {
            enableLevel = data.enableLevel or 20,
            disableLevel = data.disableLevel or 80,
            address = data.address or "None",
            signalType = data.signalType or "active_low"
        }
        
        if powerControlData.address ~= "None" then
            redstone = component.proxy(component.get(powerControlData.address))
        end
    end
end

local function setRedstoneState(enable)
    if not redstone then return end
    
    local signal = 0
    if enable then
        signal = (powerControlData.signalType == "active_high") and 15 or 0
    else
        signal = (powerControlData.signalType == "active_high") and 0 or 15
    end

    for side = 0, 5 do
        redstone.setOutput(side, signal)
    end
end

local function getPercentage(data)
    if not data or not data.storedEU or not data.EUCapacity or data.EUCapacity == 0 then
        return 0
    end
    return (data.storedEU / data.EUCapacity) * 100
end

local refresh = nil
local currentConfigWindow = {}
local function changeRedstone(redstoneAddress, data)
    if redstoneAddress == "None" then
        powerControlData.address = "None"
        redstone = nil
    else
        redstone = component.proxy(component.get(redstoneAddress))
        powerControlData.address = redstoneAddress
    end
    save()
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
            table.insert(onActivation, {displayName = address, value = changeRedstone, args = {address, renderingData}})
        end
    end
    table.insert(onActivation, {displayName = "None", value = changeRedstone, args = {"None", renderingData}})

    currentConfigWindow = {
        gui.smallButton(x+15, y+2, powerControlData.address:sub(1,8) or "None", gui.selectionBox, {x+16, y+2, onActivation})
    }

    local function toggleRedstoneMode()
        if powerControlData.signalType == "active_low" then
            powerControlData.signalType = "active_high"
        else
            powerControlData.signalType = "active_low"
        end
        save()              
        setRedstoneState(false)
        refresh(x, y, gui, graphics, renderer, page)
    end

    table.insert(currentConfigWindow, gui.smallButton(
        x+1, y+6,
        (powerControlData.signalType == "active_low") and "Normal Mode (0=ON)" or "Inverted Mode (15=ON)",
        toggleRedstoneMode
    ))

    local _, ySize = graphics.context().gpu.getBufferSize(page)
    table.insert(currentConfigWindow, gui.smallButton(x+15, y+2, powerControlData.address or "None", gui.selectionBox, {x+16, y+2, onActivation}))
    table.insert(currentConfigWindow, gui.bigButton(x+2, y+tonumber(ySize)-4, "Save Configuration", save))

    local attributeChangeList = {
        {
            name = "Activate Below (%)",
            attribute = "enableLevel",
            type = "number",
            min = 0,
            max = 100,
            defaultValue = 20
        },
        {
            name = "Deactivate Above (%)",
            attribute = "disableLevel",
            type = "number",
            min = 0,
            max = 100,
            defaultValue = 80
        }
    }
    
    gui.multiAttributeList(x+3, y+3, page, currentConfigWindow, attributeChangeList, powerControlData)

    renderer.update()
    return currentConfigWindow
end
refresh = powerControl.configure

load()
local currentRedstoneState = nil
function powerControl.update(data)
    if counter >= checkingInterval then
        if data and data.power and redstone then
            local percent = getPercentage(data.power)
            if percent <= powerControlData.enableLevel and currentRedstoneState ~= true then
                setRedstoneState(true)
                currentRedstoneState = true
            elseif percent >= powerControlData.disableLevel and currentRedstoneState ~= false then
                setRedstoneState(false)
                currentRedstoneState = false
            end
        end
        counter = 0
    else
        counter = counter + 1
    end
end

return powerControl