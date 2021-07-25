
local C = require("component"); local screen = require("term"); local event = require("event"); local uc = require("unicode")

local S = require("serialization")
gpu = C.gpu
gpu.fill(1, 1, 80, 25, " ")
local categoryID = 1; local taskID = 1; local categoryAddY = 0; local editing = false; local editableData = {}
local categoryColor = 0xFF00FF
local taskColor = 0xFFFF00
local playerColor = 0x00FFFF
local borderColor = 0x888888
local editingColor = 0x009999
local board = {categories = {}, categoryID = 1, taskID = 1}
local function contains(y)
    for c = 1, #board.categories do
        local category = board.categories[c]
        if category.y == y then return category
        elseif #category.tasks > 0 then
            for t = 1, #category.tasks do if category.tasks[t].y == y then return category.tasks[t] end end
        end
    end
end
local function trueY(y) return math.ceil(y/2) end
--Basic textbox, uses background color
function text(x, y, text, colour, GPU)
    if y%2 == 0 then error("Y ("..y..") must be odd"); return end
    GPU = GPU or C.gpu
    local oldBG = GPU.getBackground(); local oldFG = GPU.getForeground()
    local _, _, background = GPU.get(x, trueY(y))
    GPU.setBackground(background)
    GPU.setForeground(colour)
    GPU.set(x, trueY(y), text)
    GPU.setBackground(oldBG); GPU.setForeground(oldFG)
end
local function addCategory()
    board.categories[#board.categories+1] = {id = categoryID, name = "New Category", tasks = {}, y=0}
    categoryID = categoryID + 1
    board.categoryID = categoryID
end
local function removeCategory(id)
    local removed = false
    local categories = #board.categories
    for c = 1, categories do
        if board.categories[c].id == id then
            board.categories[c] = nil
            removed = true
        end
        if removed then 
            if c < categories then board.categories[c] = board.categories[c+1] else board.categories[c] = nil end
        end
    end
end
local function addTask(parent, id)
    local p = 1
    for p = 1, #board.categories do
        if board.categories[p].id == parent then
            board.categories[p].tasks[#board.categories[p].tasks+1] = {id = taskID, name = "New Task "..taskID, y=0, players = {}}
            taskID = taskID + 1
            board.taskID = taskID
            return
        end
    end
end
local function removeTask(parent, id)
    for p = 1, #board.categories do
        if board.categories[p].id == parent then
            local removed = false
            local category = board.categories[p]
            local tasks = #category.tasks
            for t = 1, tasks do
                if category.tasks[t].id == id then
                    board.categories[p].tasks[t] = nil
                    removed = true
                end
                if removed then 
                    if t < tasks then board.categories[p].tasks[t] = board.categories[p].tasks[t+1] else board.categories[p].tasks[t] = nil end
                end
            end
        end
    end
end
local function addPlayer(parent, task, player)
    for p = 1, #board.categories do
        if board.categories[p].id == parent then
            for t = 1, #board.categories[p].tasks do
                if board.categories[p].tasks[t].id == task then
                    board.categories[p].tasks[t].players[#board.categories[p].tasks[t].players+1] = player
                    return
                end
            end
        end
    end
end
local function removePlayer(parent, task, player)
    for p = 1, #board.categories do
        if board.categories[p].id == parent then
            for t = 1, #board.categories[p].tasks do
                if board.categories[p].tasks[t].id == task then
                    local removed = false
                    local category = board.categories[p]
                    local task = category.tasks[t]
                    local players = #task.players
                    for f = 1, #task.players do
                        if task.players[f] == player then
                            board.categories[p].tasks[t].players[f] = nil
                            removed = true
                        end
                        if removed then 
                            if t < players then board.categories[p].tasks[t].players[f] = board.categories[p].tasks[t].players[f+1] else board.categories[p].tasks[t].players[f] = nil end
                        end
                    end
                end
            end
        end
    end
end
local function save()
    local file = io.open("taskData", "w")
    file:write(S.serialize(board))
    file:close()
end

local function load()
    local file = io.open("taskData", "r")
    if file == nil then
        board = {
            categories = {
            },
            categoryID = 1,
            taskID = 1
        } 
    else
        board = S.unserialize(file:read("*a"))
        categoryID = board.categoryID
        taskID = board.taskID
        file:close()
    end
end
local xLocation = 1
local yLocation = 1
local displayWidth = 48
local taskWidth = 18
local boardWidth = 0
local function display(x, y, width, taskWidth)
    gpu.fill(1, 2, 80, 25, " ")
    local topBarrier = "╭────┬"
    local barrier = "│    │"
    local categoryBarrier = "├────┼"
    local bottomBarrier = "╰────┴"
    for b = 1, width-7 do
        if b == taskWidth+6 then
            topBarrier = topBarrier.."┬"
            barrier = barrier.."│"
            categoryBarrier = categoryBarrier.."┼"
            bottomBarrier = bottomBarrier.."┴"
        else
            topBarrier = topBarrier.."─"
            barrier = barrier.." "
            categoryBarrier = categoryBarrier.."─"
            bottomBarrier = bottomBarrier.."─"
        end
    end
    topBarrier = topBarrier.."╮"
    barrier = barrier.."│"
    categoryBarrier = categoryBarrier.."┤"
    bottomBarrier = bottomBarrier.."╯"
    local offset = 0
    for i = 1, #board.categories do
        local category = board.categories[i]
        offset = offset + 2
        board.categories[i].y = y+offset/2
        text(x, y+offset-2, categoryBarrier, borderColor)
        text(x, y+offset, barrier, borderColor)
        text(x+6, y+offset, category.name, categoryColor)
        text(x+2, y+offset, "DEL", 0xFF0000)
        text(x+taskWidth+10, y+offset, "+", 0x00FF00)
        offset = offset + 2
        for j = 1, #category.tasks do
            board.categories[i].tasks[j].y = y+offset/2
            board.categories[i].tasks[j].parent = category.id
            local task = category.tasks[j]
            text(x, y+offset, barrier, borderColor)
            text(x+9, y+offset, task.name, taskColor)
            text(x+taskWidth+10, y+offset, "-", 0xFF0000)
            text(x+1, y+offset, "JOIN", 0x00FF00)
            if #task.players > 0 then
                local playerString = ""
                for p = 1, #category.tasks[j].players do
                    playerString = playerString..task.players[p].." "
                end
                text(x+taskWidth+12, y+offset, playerString, playerColor)
            end
            offset = offset + 2
        end
    end
    text(x, y, topBarrier, borderColor)
    text(x, y+offset, bottomBarrier, borderColor)
    text(x+taskWidth/2+3, y+offset+2, "Add Category", 0x00FF00)
    categoryAddY = y+offset/2 + 1
    save()
end
local function processClick(event, address, x, y, button, player)
    --Join button and remove categories
    if x >= xLocation + 1 and x < xLocation + 5 then
        if contains(y) ~= false then 
            local data = contains(y)
            if data.tasks ~= nil then 
                removeCategory(data.id)
            else
                local function hasJoined(players, player)
                    for a = 1, #players do
                        if players[a] == player then return true end
                    end
                    return false
                end
                if hasJoined(data.players, player) then
                    removePlayer(data.parent, data.id, player)
                else
                    addPlayer(data.parent, data.id, player)
                end
            end
            display(xLocation, yLocation, displayWidth, taskWidth)
        end
    --Task addition and removal
    elseif x >= xLocation + taskWidth + 10 and x < xLocation + taskWidth + 11 then
        if contains(y) ~= false then 
            local data = contains(y)
            --Add tasks
            if data.tasks ~= nil then 
                addTask(data.id)
            else --Remove task
                removeTask(data.parent, data.id)
            end
            display(xLocation, yLocation, displayWidth, taskWidth)
        end
    --New Categories
    elseif x >= xLocation + taskWidth/2 + 2 and x < xLocation + taskWidth/2 + 14 and y == categoryAddY then
        addCategory("New Category")
        display(xLocation, yLocation, displayWidth, taskWidth)

    elseif x > xLocation + 6 and x < xLocation + taskWidth + 4 then
        if contains(y) ~= false then
            local data = contains(y)
            local line = data.y*2-1
            editableData.y = line
            editableData.name = data.name
            if data.players ~= nil then --Edit task name
                editableData.x = xLocation+9
                editableData.category = data.parent
                editableData.color = taskColor
                editableData.task = data.id
                editing = true
            else --Edit category name
                editableData.x = xLocation+6
                editableData.color = categoryColor
                editableData.category = data.id
                editableData.task = 0
                editing = true
            end
        end
    end
end
local function editText(x, y, nameString, color, category, task)
    local textString = nameString
    local value = 0
    text(x, y, textString.."_", editingColor)
    while value ~= 13 do
        _, _, key, _, _ = event.pull(1, "key_down")
        if key ~= nil then
            value = key
            if #textString < taskWidth then
                if key >= 32 and key <= 126 then
                    textString = textString..uc.char(key)
                end
            end
            if key == 8 then
                textString = textString:sub(1, -2)
            end
            local padded = textString.."_"
            for i = 2, taskWidth-#textString+1 do padded = padded.." " end
            text(x, y, padded, editingColor)
        end
    end
    if editableData.task == 0 then
        for i = 1, #board.categories do
            if board.categories[i].id == category then board.categories[i].name = textString end
        end
    else
        for i = 1, #board.categories do
            if board.categories[i].id == category then
                for j = 1, #board.categories[i].tasks do
                    if board.categories[i].tasks[j].id == task then
                        board.categories[i].tasks[j].name = textString
                    end
                end
            end
        end
    end
    editing = false
    display(xLocation, yLocation, displayWidth, taskWidth)
end
event.ignore("touch", processClick)
event.listen("touch", processClick)
load()
display(xLocation, yLocation, displayWidth, taskWidth)
screen.setCursor(1, 15)

while true do
    if editing then 
        event.ignore("touch", processClick)
        editText(editableData.x, editableData.y, editableData.name, editableData.color, editableData.category, editableData.task)
        event.listen("touch", processClick)
    end
    os.sleep(0.05)
end