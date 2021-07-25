package.path = package.path..";/NIDAS/lib/graphics/?.lua"..";/NIDAS/lib/utils/?.lua"
local component = require("component")
local computer = require("computer")
local event = require("event")
package.loaded.colors = nil
local colors = require("colors")
package.loaded.ar = nil
local ar = require("ar")
package.loaded.util = nil
local util = require("utility")
--Test Values
local glasses = component.glasses
local data = util.machine("53268277")
ar.clear(glasses)

local powerDisplay = {}

local displayInitialized = false
local hudObjects = {
    static = {},
    dynamic = {}
}
local energyData = {
    counter = 1,
    readings = {},
    first = 0,
    last = 0,
    updateInterval = 100,
    currentRate = 0
}
local sizes = {
    x = 0,
    y = 0,
    energyBarLength = 0,
    bar = 0,
    div = 3,
}
local borderColor = colors.darkGray
local primaryColor = colors.electricBlue
local accentColor = colors.magenta

--Change these two functions if you want to adapt for other power sources.
local function getCurrentEnergy(data)
    return math.floor(string.gsub(data.getSensorInformation()[2], "([^0-9]+)", "") + 0)
end
local function getMaxEnergy(data)
    return math.floor(string.gsub(data.getSensorInformation()[3], "([^0-9]+)", "") + 0)
end
local energyUnit = "RF"

--Small = 1, Normal = 2, Large = div, Auto = 4x to 10x (Even)
function powerDisplay.widget(glasses, data, w, h, resolution, scale)
    local currentEU = getCurrentEnergy(data)
    local maxEU = getMaxEnergy(data)
    if maxEU < 0 then
        maxEU = -maxEU
    end
    local percentage = math.min(currentEU/maxEU, 1.0)
    --Update I/O
    if energyData.counter == 1 then
        energyData.first = computer.uptime()
        energyData.readings[1] = currentEU
    end
    if energyData.counter < energyData.updateInterval then
        energyData.counter = energyData.counter + 1
    end
    if energyData.counter == energyData.updateInterval then
        energyData.last = computer.uptime()
        energyData.readings[2] = currentEU

        local ticks = math.ceil((energyData.last - energyData.first) * 20)
        energyData.currentRate = math.floor((energyData.readings[2] - energyData.readings[1])/ticks)
        energyData.counter = 1
    end

    if #hudObjects.static == 0 then
        local x = 0
        local y = util.screensize(resolution, scale)[2] - h
        local bar = math.ceil(h * 0.4)
        local div = sizes.div
        local rate = h-bar-2*div-1
        sizes.x = x
        sizes.y = y
        sizes.bar = bar
        sizes.energyBarLength = w-4-bar
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y}, w, h, borderColor, 0.6)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y-2}, w, 5+bar, borderColor, 0.6)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y-4}, w, 2, borderColor, 0.5)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y-6}, w, 2, borderColor, 0.4)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y-8}, w, 2, borderColor, 0.3)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y-10}, w, 2, borderColor, 0.2)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y}, w, div, borderColor)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y+div+bar}, w, div, borderColor)
        hudObjects.static[#hudObjects.static+1] = ar.rectangle(glasses, {x, y+h-1}, w, 1, borderColor)
        hudObjects.static[#hudObjects.static+1] = ar.quad(glasses, {x, y+div}, {x, y+div+bar}, {x+3+bar, y+div+bar}, {x+3, y+div}, borderColor)
        hudObjects.static[#hudObjects.static+1] = ar.quad(glasses, {x+w-1-bar, y+div}, {x+w-1, y+div+bar}, {x+w, y+div+bar}, {x+w, y+div}, borderColor)
        hudObjects.static[#hudObjects.static+1] = ar.quad(glasses, {x, y+2*div+bar}, {x, y+2*div+bar+rate}, {x+30+rate, y+2*div+bar+rate}, {x+30, y+2*div+bar}, borderColor)
        hudObjects.static[#hudObjects.static+1] = ar.quad(glasses, {x+w-30-rate, y+2*div+bar}, {x+w-30, y+2*div+bar+rate}, {x+w, y+2*div+bar+rate}, {x+w, y+2*div+bar}, borderColor)
        hudObjects.dynamic.energyBar = ar.quad(glasses, {x+3, y+div}, {x+3+bar, y+div+bar}, {x+3+bar, y+div+bar}, {x+3, y+div}, primaryColor)
        hudObjects.dynamic.currentEU = ar.text(glasses, "", {x+2, y-9}, primaryColor)
        hudObjects.dynamic.maxEU = ar.text(glasses, "", {x+w-90, y-9}, accentColor)
        hudObjects.dynamic.percentage = ar.text(glasses, "", {x+w/2-5, y-9}, accentColor)
        hudObjects.dynamic.filltime = ar.text(glasses, "Time to empty:", {x+30+rate, y+2*div+bar+3}, accentColor, 0.7)
        hudObjects.dynamic.fillrate = ar.text(glasses, "", {x+w/2-10, y+2*div+bar+2}, borderColor)
    end
    hudObjects.dynamic.energyBar.setVertex(3, sizes.x+3+sizes.bar+sizes.energyBarLength*percentage, sizes.y+sizes.div+sizes.bar)
    hudObjects.dynamic.energyBar.setVertex(4, sizes.x+3+sizes.energyBarLength*percentage, sizes.y+sizes.div)
    hudObjects.dynamic.currentEU.setText(util.splitNumber(currentEU).." "..energyUnit)
    if maxEU > 9000000000000000000 then
        hudObjects.dynamic.maxEU.setText("∞ "..energyUnit)
        hudObjects.dynamic.maxEU.setPosition(sizes.x+w-25, sizes.y-9)
    else
        hudObjects.dynamic.maxEU.setText(util.splitNumber(maxEU).." "..energyUnit)
        hudObjects.dynamic.maxEU.setPosition(sizes.x+w-30-(4.5*#util.splitNumber(maxEU)), sizes.y-9)
    end
    hudObjects.dynamic.percentage.setText(util.percentage(percentage))
    local rateString = util.splitNumber(energyData.currentRate)
    hudObjects.dynamic.fillrate.setPosition(sizes.x+w/2-10-(#rateString*1.5), sizes.y+2*sizes.div+sizes.bar+2)
    if energyData.currentRate >= 0 then
        hudObjects.dynamic.fillrate.setText("+"..rateString.." "..energyUnit.."/t") 
        hudObjects.dynamic.fillrate.setColor(util.RGB(colors.lime))
    else
        hudObjects.dynamic.fillrate.setText(rateString.." "..energyUnit.."/t")
        hudObjects.dynamic.fillrate.setColor(util.RGB(colors.red))
    end
    local fillTimeString = ""
    if w > 250 then
        if energyData.currentRate >= 0 then
            local fillTime = math.floor((maxEU-currentEU)/(energyData.currentRate*20))
            fillTimeString = "Full: " .. util.time(math.abs(fillTime))
        else
            local fillTime = math.floor((currentEU)/(energyData.currentRate*20))
            fillTimeString = "Empty: " .. util.time(math.abs(fillTime))
        end
    end 
    hudObjects.dynamic.filltime.setText(fillTimeString)
end

function powerDisplay.remove(glasses)
    for i = 1, #hudObjects.static do
        glasses.removeObject(hudObjects.static[i].getID())
    end
    glasses.removeObject(hudObjects.dynamic.energyBar.getID())
    glasses.removeObject(hudObjects.dynamic.currentEU.getID())
    glasses.removeObject(hudObjects.dynamic.maxEU.getID())
    glasses.removeObject(hudObjects.dynamic.percentage.getID())
    glasses.removeObject(hudObjects.dynamic.filltime.getID())
    glasses.removeObject(hudObjects.dynamic.fillrate.getID())
end

powerDisplay.widget(glasses, data, 337, 29, {2560, 1440}, 3)
