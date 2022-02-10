local component = require("component")
local serialization = require("serialization")
local transforms = require("transforms")
local states         = require("server.entities.states")
local colors         = require("graphics.colors")
local autostocker = {}

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")

local interface = component.me_interface
local craftablesList = {}
local stockingLevels = {}
local currentlyCrafting = {}
local requestTrackers = {}
local windowRefresh = nil
local currentConfigWindow = {}
local failures = {}
local searchKey = {keyword = ""}
local function save()
    local file = io.open("/home/NIDAS/settings/stockingLevels", "w")
    file:write(serialization.serialize(stockingLevels))
    file:close()
    windowRefresh(searchKey.keyword)
end

local function load()
    local file = io.open("/home/NIDAS/settings/stockingLevels", "r")
    if file then
        stockingLevels = serialization.unserialize(file:read("*a")) or {}
        file:close()
        renderer.update()
    end
end

local x = 18
local y = 1
local width = 50
local maxLines = graphics.context().height - 12
local log = {""}

local function printLog(newline, color)
    color = color or 0xFFFFFF
    if inView then
        table.insert(log, 1, {text = newline, color = color})
        if #log > maxLines then
            table.remove(log, maxLines)
        end
        graphics.rectangle(x+width+1, 3, graphics.context().width-x-width-1, maxLines*2, colors.black)
        for i = 1, #log-1 do
            graphics.text(x+width+1, 1+(2*i), log[#log-i].text, log[#log-i].color)
        end
    end
end

local activePattern = ""
local renderedPattern = ""

local function getName(pattern)
    return string.gmatch(pattern, "[^%|]+")()
end

local editorPage = nil
local saveButton = nil
local numberInput = {}
local function stockingEditor()
    local context = graphics.context()
    local height = context.height-7
    if activePattern ~= renderedPattern then
        if #numberInput ~= 0 then
            renderer.removeObject(numberInput)
        end
        editorPage = gui.listFrame(x+width+1, height-3, context.width - width - 2 - x, 6, "Stocking Editor")
        renderedPattern = activePattern
        context.gpu.setActiveBuffer(editorPage)
        graphics.rectangle(2, 5, context.width - width - 4 - x, 6, colors.black) --Clear the background
        graphics.text(4, 5, "Pattern: ", gui.accentColor())
        graphics.text(13, 5, getName(activePattern) or "ERROR", 0xFFFFFF)
        graphics.text(4, 7, "Stocking to: ", gui.accentColor())
        context.gpu.setActiveBuffer(0)
        local buttonWidth = 13
        graphics.rectangle(x+width+17, 2*height - 1, buttonWidth, 2, colors.black)
        numberInput = gui.multiAttributeList(x+width+16, height - 1, editorPage, numberInput, {{name = "", attribute = activePattern, type = "number", defaultValue = 0}}, stockingLevels, nil, buttonWidth)
        saveButton = gui.bigButton(x+width+1, height+3, "Add to stocking list", save, {}, context.width - width - 2 - x, false)
        local editorPages = numberInput
        table.insert(editorPages, 1, editorPage)
        table.insert(editorPages, 1, saveButton)
        renderer.update(editorPages)
    end
end

local function changeActivePattern(patternName)
    activePattern = patternName
end

function filterByLabel(data, keyword)
    local filtered = {}
    for key, value in pairs(data) do
        if string.find(string.lower(key), string.lower(keyword)) ~= nil then
            filtered[key] = value
        end
    end
    return filtered
end

local function sortByStockLevel(data, stocklevels)

end

local idPages = nil
local levelPage = nil
local function displayPatterns(filterString)
    filterString = filterString or ""
    local context = graphics.context()
    local height = context.height-5
    maxEntries = height-3
    context.gpu.fill(x+1, y+1, width-2, height-2, " ")
    local function formCurrentView(patterns)
        if idPages ~= nil then
            renderer.removeObject(idPages)
        end
        local buttons = {}
        local i = 1
        for uniqueID, _ in pairs(patterns) do
            label = getName(uniqueID)
            local onActivation = {
                {
                    displayName = "Edit Stocking Level",
                    value = changeActivePattern,
                    args = {uniqueID}
                }
            }
            table.insert(
                buttons,
                {name = label, func = gui.selectionBox, args = {x + width / 2, y + i, onActivation}}
            )
            i = i + 1
            if i > maxEntries then break end
        end
        idPages = gui.multiButtonList(x, y, buttons, width, height, "Patterns", colors.white, true)
        if levelPage == nil then
            levelPage = gui.listFrame(1, 1, x - 1, height, "Levels")
        end
        context.gpu.setActiveBuffer(levelPage)
        graphics.rectangle(2, 5, x-3, 2*(height)-6, colors.black)
        local row = 5
        i = 1
        for label, _ in pairs(patterns) do
            local wantedLevel = stockingLevels[label] or 0
            if wantedLevel > 0 then
                graphics.text((x)/2 - (#tostring(wantedLevel))/2 + 1, row, tostring(wantedLevel), gui.accentColor())
            end
            row = row + 2
            i = i + 1
            if i > maxEntries then break end
        end
        context.gpu.setActiveBuffer(0)
    end
    local filteredPatterns = filterByLabel(craftablesList, filterString)
    formCurrentView(filteredPatterns)
    table.insert(idPages, 1, levelPage)
    renderer.update(idPages)
end

windowRefresh = displayPatterns
local function searchBox()
    local context = graphics.context()
    local searchFrame = renderer.createObject(x, context.height-4, width, 3)
    local top = "╭"
    local middle = "│"
    local bottom = "╰"
    for i = 1, width-2 do
        top = top .. "─"
        middle = middle .. " "
        bottom = bottom .. "─"
    end
    top = top .. "╮"
    middle = middle .. "│"
    bottom = bottom .. "╯"
    context.gpu.setActiveBuffer(searchFrame)
    graphics.text(1, 1, top, gui.primaryColor())
    graphics.text(1, 3, middle, gui.primaryColor())
    graphics.text(1, 5, bottom, gui.primaryColor())
    graphics.text(2, 3, "Search:", 0xFFFFFF)
    gui.multiAttributeList(x, context.height-4, searchFrame, currentConfigWindow, {{name = "Search: ", attribute = "keyword", type = "string", defaultValue = ""}}, searchKey, nil, 35)
end

initialized = false
local function discoverPatterns(amount)
    amount = amount or 100000
    local context = graphics.context()
    local frame = gui.listFrame(context.width/2 - 11, context.height/2-3, 26, 4, "Discovering Patterns")
    renderer.update()
    local craftables = interface.getCraftables()
    local total = #craftables
    context.gpu.setActiveBuffer(0)
    graphics.text(context.width/2 + 1, context.height-4, "/ "..tostring(total), gui.primaryColor())
    graphics.text(context.width/2 - #tostring(total), context.height-4, "_", gui.primaryColor())
    for i, craftable in pairs(craftables) do
        if i ~= "n" then
            graphics.text(context.width/2 - #tostring(total), context.height-4, tostring(i), gui.accentColor())
        end
        if craftable ~= total then --Check for last entry
            local itemStack = craftable.getItemStack()
            craftablesList[itemStack.label.."|"..tostring(itemStack.damage)] = craftable.request
        end
        if i == amount then
            graphics.text(context.width/2 - 5, context.height-4, "DEBUG", gui.accentColor())
            break
        end
    end
    if not initialized then
        local cpus = component.me_interface.getCpus()
        local occupiedCpus = 0
        for i = 1, #cpus do
            if cpus[i].busy then occupiedCpus = occupiedCpus + 1 end
        end
        if occupiedCpus > 0 then
            graphics.text(context.width/2 - 6, context.height-4, "Waiting for CPUs", gui.accentColor())
        end
        while occupiedCpus > 0 do
            local cpus = component.me_interface.getCpus()
            occupiedCpus = 0
            for i = 1, #cpus do
                if cpus[i].busy then occupiedCpus = occupiedCpus + 1 end
            end
            os.sleep()
        end
    end
    renderer.removeObject(frame)
    context.gpu.fill(1, 1, context.width, context.height-2, " ")
    displayPatterns()
    renderer.update()
    initialized = true
end

inView = false
local function returnToMenu()
    inView = false
    renderer.switchWindow("main")
    renderer.clearWindow("autostocker")
    renderer.update()
end

local function displayView()
    inView = true
    load()
    local context = graphics.context()
    renderer.switchWindow("autostocker")
    gui.smallButton(1, (context.height), "< < < Return", returnToMenu, {}, nil, gui.primaryColor())
    local divider = renderer.createObject(1, context.height - 1, context.width, 1)
    context.gpu.setActiveBuffer(divider)
    local bar = ""
    for i = 1, context.width do bar = bar .. "▂" end
    graphics.text(1, 1, bar, gui.borderColor())
    context.gpu.setActiveBuffer(0)
    if not initialized then
        discoverPatterns() --Debug number
        searchBox()
        stockingEditor()
    else
        idPages = nil
        levelPage = nil
        displayPatterns()
        searchBox()
        stockingEditor()
    end
    renderer.update()
end

function autostocker.windowButton()
    return {name = "Autostocker", func = displayView}
end

function autostocker.configure(x, y, _, _, _, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.context().gpu.setActiveBuffer(page)
    renderer.update()
    return currentConfigWindow
end

local cpuTimeout = 0
local function requestCraft(pattern, amount)
    local cpus = component.me_interface.getCpus()
    local occupiedCpus = 0
    for i = 1, #cpus do
        if cpus[i].busy then occupiedCpus = occupiedCpus + 1 end
    end
    if occupiedCpus < #cpus then
        if craftablesList[pattern] ~= nil then
            local tracker = craftablesList[pattern](amount)
            if tracker.isCanceled() then
                local _, reason = tracker.isCanceled()
                if not failures[pattern] then
                    --printLog("Ordering "..tostring(math.floor(amount)).."x failed:", 0xFFFFFF)
                    printLog("F "..tostring(math.floor(amount)).."x "..getName(pattern), colors.red)
                end
                failures[pattern] = true
            else
                table.insert(requestTrackers, 1, {pattern = pattern, tracker = tracker})
                currentlyCrafting[pattern] = amount
                --printLog("Ordered "..tostring(math.floor(amount)).."x of:", 0xFFFFFF)
                printLog("+ "..tostring(math.floor(amount)).."x "..getName(pattern), colors.green)
                if failures[pattern] then
                    failures[pattern] = false
                end
            end
        end
    else
        if cpuTimeout == 0 then
            printLog("No free CPUs to order!")
            cpuTimeout = 5000
        end
    end
end

local hysteresis = 0.05
local itemsPerCycle = 10
local itemIterator = nil
local function doCraftingTasks()
    if itemIterator == nil then
        itemIterator = component.me_interface.allItems()
    end
    for i = 1, itemsPerCycle do
        local item = itemIterator()
        if item ~= nil then
            local label = item.label.."|"..item.damage
            --printLog(label, 0xFFFFFF)
            local stockingLevel = stockingLevels[label] or 0
            if stockingLevel > 0  then
                local stocked = item.size
                local ordered = currentlyCrafting[label] or 0
                if stocked + ordered < (math.ceil(stockingLevel*(1-hysteresis))) then
                    requestCraft(label, stockingLevel - stocked - ordered)
                end
            end
        else
            itemIterator = nil
            break
        end
    end
end

local function checkFinishedTasks()
    for i = 1, #requestTrackers do
        local tracker = requestTrackers[i]
        if tracker ~= nil then
            if tracker.tracker.isCanceled() then
                printLog("- "..tostring(math.ceil(currentlyCrafting[tracker.pattern])).."x "..getName(tracker.pattern), gui.accentColor())
                currentlyCrafting[tracker.pattern] = 0
                table.remove(requestTrackers, i)
            elseif tracker.tracker.isDone() then
                printLog("R "..tostring(math.ceil(currentlyCrafting[tracker.pattern])).."x "..getName(tracker.pattern), gui.primaryColor())
                currentlyCrafting[tracker.pattern] = 0
                table.remove(requestTrackers, i)
            end
        end
    end
end


local lastKeyword = searchKey.keyword
function autostocker.update(data)
    if inView and data ~= nil then
        graphics.context().gpu.setActiveBuffer(0)
    end
    if inView and (lastKeyword ~= searchKey.keyword) then
        displayPatterns(searchKey.keyword)
        lastKeyword = searchKey.keyword
    end
    if initialized and (cpuTimeout == 0) then
        doCraftingTasks()
        checkFinishedTasks()
    end
    if cpuTimeout ~= 0 then
        cpuTimeout = cpuTimeout - 1
    end
    stockingEditor()
end

return autostocker