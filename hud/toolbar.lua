local internet = require("internet")
local colors = require("graphics.colors")
local ar = require("graphics.ar")
local screen = require("utils.screen")
local time = require("utils.time")

local toolbar = {}

local hudObjects = {}
local realtime = ""
local requestCounter = 500
function toolbar.widget(glasses)
    if #hudObjects == 0 then
        for i = 1, #glasses do
            if glasses[i][1] == nil then
                error("Must provide glass proxy for toolbar.")
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
                accentColor     = glasses[i][7] or colors.magenta
            })
        end
    end 
    local w = 183
    local h = 42
    local hExpBar = 5
    local clockWidth = 88
    local clockheight = 10
    local rightTriangleSide = 30
    local middleTriangleSide = 9
    local timeString = os.date()
    local day = timeString:sub(1, 2)
    local month = timeString:sub(4, 5)
    local date = day + (month-1) * 30
    local year = timeString:sub(7, 8)
    local hours = timeString:sub(10, #timeString-3)
    year = year - 70 + 0
    timeString = hours.." | ".."Day "..math.floor(date).." Year "..math.floor(year)
    if requestCounter == 500 then
        realtime = internet.request("http://worldclockapi.com/api/json/utc/now")()
        requestCounter = 1
    end
    for i = 1, #hudObjects do
        local resolution = screen.size(hudObjects[i].resolution, hudObjects[i].scale)
        local x = resolution[1] / 2 - w/2
        local y = resolution[2] - h
        local formattedTime = time.offset(hudObjects[i].offset, realtime)
        if #hudObjects[i].static == 0 and #hudObjects[i].glasses ~= nil then
            local borderColor = hudObjects[i].borderColor
            local primaryColor = hudObjects[i].primaryColor
            local accentColor = hudObjects[i].accentColor
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x+w+3, y+9}, clockWidth+2, clockheight+2, borderColor)) --Clock Base
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x, y-10}, w+1, 12, borderColor, 0)) --Hide Armor
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x, y+3}, 2, h-3, borderColor)) --Left Border
            table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x+3, y}, {x, y+3}, {x+w+3, y+3}, {x+w, y}, borderColor)) -- Top Border
            table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x+w, y}, {x+w, y+h}, {x+w+rightTriangleSide, y+h}, {x+w+rightTriangleSide, y+rightTriangleSide}, borderColor)) --Right triangle
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x+w-1, y+15}, 2, h-15, borderColor)) --Right Toolbar Edge
            table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x+w/2-middleTriangleSide+5, y+3}, {x+w/2-2*middleTriangleSide+5, y+3+middleTriangleSide}, {x+w/2+2*middleTriangleSide-3, y+3+middleTriangleSide}, {x+w/2+middleTriangleSide-3, y+3}, borderColor)) --Middle Triangle
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x, y+12}, w, 3, borderColor)) --Middle Divider
            table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x+2, y+15}, {x+2+hExpBar, y+15+hExpBar}, {x+w, y+15+hExpBar}, {x+w-hExpBar, y+15}, primaryColor, 0.5)) --Experience Bar
            table.insert(hudObjects[i].static, ar.triangle(hudObjects[i].glasses, {x+2, y+15}, {x+2, y+15+hExpBar},{x+2+hExpBar, y+15+hExpBar}, borderColor)) -- Experience Left
            table.insert(hudObjects[i].static, ar.triangle(hudObjects[i].glasses, {x+w-hExpBar, y+15}, {x+w, y+15+hExpBar},{x+w, y+15}, borderColor)) -- Experience Right
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x, y+19}, w, 2, borderColor)) --Bottom Divider
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x+4, y+1}, w-4, 1, primaryColor)) -- Top Strip
            table.insert(hudObjects[i].static, ar.quad(hudObjects[i].glasses, {x+w, y+1}, {x+w, y+2}, {x+w+rightTriangleSide-1, y+1+rightTriangleSide},  {x+w+rightTriangleSide-1, y+rightTriangleSide}, primaryColor)) --Diagonal Strip
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x+w+rightTriangleSide-2, y+rightTriangleSide}, 1, h-rightTriangleSide, primaryColor)) --Right Strip
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x+w+4, y+10}, clockWidth, clockheight, primaryColor)) --Clock Edge
            table.insert(hudObjects[i].static, ar.rectangle(hudObjects[i].glasses, {x+w+5, y+11}, clockWidth-2, clockheight-2, borderColor)) --Clock Panel
            hudObjects[i].dynamic.clock = ar.text(hudObjects[i].glasses, "", {x+w+7, y+13}, accentColor, 0.65)
            hudObjects[i].dynamic.realtime = ar.text(hudObjects[i].glasses, "", {x+w+3, y+30}, primaryColor, 0.8)
        end
        hudObjects[i].dynamic.clock.setText(timeString)
        if formattedTime ~= nil then
            hudObjects[i].dynamic.realtime.setText(formattedTime)
        end
    end
    requestCounter = requestCounter + 1
end

function toolbar.remove()
    for i = 1, #hudObjects do
        for j = 1, #hudObjects[i].static do
            hudObjects[i].glasses.removeObject(hudObjects[i].static[j].getID())
        end
        hudObjects[i].glasses.removeObject(hudObjects[i].dynamic.clock.getID())
        hudObjects[i].glasses.removeObject(hudObjects[i].dynamic.realtime.getID())
    end
end

return toolbar