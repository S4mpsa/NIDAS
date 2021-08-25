local colors = require("lib.graphics.colors")
local ar = require("lib.graphics.ar")
local event = require("event")
local screen = require("lib.utils.screen")
local serialization = require("serialization")
local states         = require("server.entities.states")
local gui = require("lib.graphics.gui")

local notifications = {}
local hudObjects = {}

local startY = 40
local stepModifier = 3

function event.onError(message)
    error(message)
end

local function notification(data, string, timeout, color, forceSlot)
    local yModifier = forceSlot or nil
    if not forceSlot then
        for i = 1, #data.notifications do
            if not data.notifications[i] then
                yModifier = i
                data.notifications[i] = true
                break
            end
        end
    end
    if yModifier then
        local glasses = data.glasses
        local width = 18 + #string * 4.8
        local y = startY + yModifier * 10
        local x = 0
        local stepSize = stepModifier * math.ceil(width / 30)
        local top = ar.quad(glasses, {x, y}, {x, y+1}, {x, y+1}, {x, y}, data.borderColor, 0.8)
        local bottom = ar.quad(glasses, {x, y+10}, {x, y+11}, {x, y+11}, {x, y+10}, data.borderColor, 0.8)
        local background = ar.quad(glasses, {x, y+1}, {x, y+10}, {x, y+10}, {x, y+1}, data.borderColor, 0.4)
        local text = ar.text(glasses, string, {-width, y+2}, color or data.primaryColor)
        local stepsTaken = 0
        local totalSteps = width / stepSize
        local direction = 1
        local function advance()
            stepsTaken = stepsTaken + direction
            top.setVertex(3, x + stepSize * stepsTaken, y+1)
            top.setVertex(4, x + stepSize * stepsTaken - 1, y)
            bottom.setVertex(3, x + stepSize * stepsTaken/1.5 - 1, y+11)
            bottom.setVertex(4, x + stepSize * stepsTaken/1.5, y+10)
            background.setVertex(3, x + stepSize * stepsTaken - 8 - 1, y+10)
            background.setVertex(4, x + stepSize * stepsTaken, y+1)
            text.setPosition(math.min(x+1, x + -width + stepSize * stepsTaken + 1), y+2)
            if direction == -1 and stepsTaken == 0 then
                glasses.removeObject(top.getID())
                glasses.removeObject(bottom.getID())
                glasses.removeObject(background.getID())
                glasses.removeObject(text.getID())
            end
        end
        local function retract()
            direction = -1
            event.timer(0.05, advance, totalSteps)
            data.notifications[yModifier] = false
        end
        event.timer(0.05, advance, totalSteps)
        if timeout then event.timer(timeout, retract) else return retract end
    else
        table.insert(data.queue, {string, timeout, color})
        return false
    end
end

local function startup(data, startN, endN)
        local glasses = data.glasses
        local width = 40
        local height = 11 * (endN - startN)
        local y = startY
        local x = 0
        local stepSize = stepModifier * math.ceil(width / 30)
        local top = ar.quad(glasses, {x, y}, {x, y+1}, {x, y+1}, {x, y}, data.borderColor, 0.8)
        local bottom = ar.quad(glasses, {x, y+height}, {x, y+height+1}, {x, y+height+1}, {x, y+height}, data.borderColor, 0.8)
        local background = ar.quad(glasses, {x, y+1}, {x, y+height}, {x, y+height}, {x, y+1}, data.borderColor, 0.4)
        local text = ar.text(glasses, "          "..tostring(startN), {-width, y+2}, data.primaryColor)
        local text2 = ar.text(glasses, "          "..tostring(endN), {-width, y+height-10}, data.primaryColor)
        local stepsTaken = 0
        local totalSteps = width / stepSize
        local direction = 1
        local function advance()
            stepsTaken = stepsTaken + direction
            top.setVertex(3, x + stepSize * stepsTaken, y+1)
            top.setVertex(4, x + stepSize * stepsTaken - 1, y)
            bottom.setVertex(3, x + stepSize * stepsTaken - 1, y+height+1)
            bottom.setVertex(4, x + stepSize * stepsTaken, y+height)
            background.setVertex(3, x + stepSize * stepsTaken, y+height)
            background.setVertex(4, x + stepSize * stepsTaken, y+1)
            text.setPosition(math.min(x+1, x + -width + stepSize * stepsTaken - 1), y+2)
            text2.setPosition(math.min(x+1, x + -width + stepSize * stepsTaken - 1), y+height-10)
            if direction == -1 and stepsTaken == 0 then
                glasses.removeObject(top.getID())
                glasses.removeObject(bottom.getID())
                glasses.removeObject(background.getID())
                glasses.removeObject(text.getID())
                glasses.removeObject(text2.getID())
            end
        end
        local function retract()
            direction = -1
            event.timer(0.05, advance, totalSteps)
        end
        event.timer(0.05, advance, totalSteps)
        event.timer(1.5, retract)
end

function notifications.addNotification(text, timeout, color)
    local retracts = {}
    for i = 1, #hudObjects do
        local hudObject = hudObjects[i]
        local retractFunc = notification(hudObject, text, timeout, color)
        if not timeout then table.insert(retracts, retractFunc) end
    end
    local function retractAll()
        --Remove notifications from queue if they were never shown
        for i = 1, #retracts do
            if retracts[i] == false then
                for j = 1, #hudObjects do
                    for k = 1, #hudObjects[j].queue do
                        if hudObjects[j].queue[k][1] == text then
                            table.remove(hudObjects[j].queue, k)
                            break
                        end
                    end
                end
            else
                retracts[i]()
            end
        end
    end
    if not timeout then return retractAll end
end

local function processQueue(hudObject)
    local queue = hudObject.queue[1]
    for i = 1, #hudObject.notifications do
        if not hudObject.notifications[i] then
            table.remove(hudObject.queue, 1)
            notification(hudObject, queue[1], queue[2], queue[3])
            break
        end
    end
end


local displayedMachines = {}
local function displayMaintenance(_, serializedData)
    local statusData = serialization.unserialize(serializedData)
    for address, values in pairs(statusData) do
        if values.state.name == states.OFF.name then
            local displayString = values.name or address
            displayedMachines[address] = notifications.addNotification(displayString .. " is disabled", nil, 0xFF0000)
            --Add location displaying here
        elseif values.state.name == states.BROKEN.name then
            local displayString = values.name or address
            displayedMachines[address] = notifications.addNotification(displayString .. " requires maintenance", nil, gui.accentColor())
            --Add location displaying here
        end
        if displayedMachines[address] then
            if values.state.name == states.ON.name or values.state.name == states.IDLE.name then
                displayedMachines[address]()
                displayedMachines[address] = nil
            end
        end
    end
end

function notifications.widget(glasses)
    if #hudObjects < #glasses then
        for i = 1, #glasses do
            if glasses[i][1] == nil then
                error("Must provide glass proxy for notification service.")
            end
            local ySize = screen.size(glasses[i][2] or {2560, 1440}, glasses[i][3])[2] / 1.55
            local notificationTable = {}
            for j = 1, ySize / 10 do
                notificationTable[j] = false
            end
            table.insert(hudObjects,  {
                static          = {},
                dynamic         = {},
                glasses         = glasses[i][1],
                resolution      = glasses[i][2] or {2560, 1440},
                scale           = glasses[i][3] or 3,
                offset          = glasses[i][4] or 0,
                borderColor     = glasses[i][5] or colors.darkGray,
                primaryColor    = glasses[i][6] or colors.electricBlue,
                accentColor     = glasses[i][7] or colors.magenta,
                notifications   = notificationTable,
                queue           = {}
            })
            local function doStartup()
                startup(hudObjects[i], 1, #notificationTable)
            end
            --The next line is to prevent the HUD animations firing off before rest of the HUD is drawn.
            event.timer(3, doStartup, 1)
        end
        event.listen("notification", displayMaintenance)
    end
    for i = 1, #hudObjects do
        local hudObject = hudObjects[i]
        if #hudObject.queue > 0 then
            processQueue(hudObject)
        end
    end
end

return notifications