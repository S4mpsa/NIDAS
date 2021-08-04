local component = require("component")

local redstone = nil

local function getPercentage(data)
    return data.storedEU / data.EUCapacity
end

local function setRedstone(address)
    redstone = component.proxy(component.get(address)) or component.redstone
end

local engaged = false
local function disengage()
    print("Disengaging generators.")
    redstone.setOutput({0, 0, 0, 0, 0, 0})
    engaged = false
end
local function engage()
    print("Engaging generators.")
    redstone.setOutput({15, 15, 15, 15, 15, 15})
    engaged = true
end


local function update(data, redstoneAddress)
    redstoneAddress = redstoneAddress or "NONE"
    if redstone == nil then setRedstone(redstoneAddress) end
    local level = getPercentage(data)
    if level < 0.85 then
        if not engaged then engage() end
    elseif level > 0.99 then
        if engaged then disengage() end
    end
end

return update