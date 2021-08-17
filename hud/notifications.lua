local colors = require("lib.graphics.colors")
local ar = require("lib.graphics.ar")
local event = require("event")
local screen = require("lib.utils.screen")

local notifications = {}
local hudObjects = {}

local startY = 40
local stepModifier = 3

local function notification(data, string, timeout, color)
    local yModifier = nil
    for i = 1, #data.notifications do
        if not data.notifications[i] then
            yModifier = i
            data.notifications[i] = true
            break
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
            local flashed = {}
            local function flashNotification()
                table.insert(flashed, notification(hudObjects[i], tostring(#flashed), _, hudObjects[i].borderColor))
            end
            local function retractFlashed()
                local n = 1
                local function retract()
                    flashed[n]()
                    n  = n + 1
                end
                event.timer(0.05, retract, #flashed + 1)
            end
            event.timer(0.05, flashNotification, #notificationTable)
            event.timer(0.1*#notificationTable+1, retractFlashed)
        end
    end
    for i = 1, #hudObjects do
        local hudObject = hudObjects[i]
        if #hudObject.queue > 0 then
            processQueue(hudObject)
        end
    end
end









return notifications