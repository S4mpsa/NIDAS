local component = require("component")

local powerControl = {}

local redstone = nil

local function getPercentage(data)
    return data.storedEU / data.EUCapacity
end

local function setRedstone(address)
    --redstone = component.proxy(component.get(address)) or component.redstone
    redstone = component.redstone
end

local engaged = false
local function disengage()
    redstone.setOutput({0, 0, 0, 0, 0, 0})
    engaged = false
end
local function engage()
    redstone.setOutput({15, 15, 15, 15, 15, 15})
    engaged = true
end

function powerControl.configure(x, y)
    
end

function powerControl.update(data, redstoneAddress)
    redstoneAddress = redstoneAddress or "NONE"
    local level = getPercentage(data.power)
    if redstone == nil then
        setRedstone(redstoneAddress)
        if level < 0.85 then engaged = false else engaged = true end
    end
    if level < 0.85 then
        if not engaged then engage() end
    elseif level > 0.99 then
        if engaged then disengage() end
    end
end

return powerControl