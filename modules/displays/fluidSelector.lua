local component = require("component")
local serialization = require("serialization")
local transforms = require("transforms")
local states         = require("server.entities.states")
local colors         = require("graphics.colors")
local fluidColors = require("graphics.fluidColors")
local fluidDisplay = {}

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")
local hud = require("hud.init")

local fluidsList = {}
local userFluids = {}
local windowRefresh = nil
local currentConfigWindow = {}
local configurationData = {}
local searchKey = {keyword = ""}
local selectedGlasses = nil
local updateFlag = false

local function save()
    local file = io.open("/home/NIDAS/settings/userFluids", "w")
    file:write(serialization.serialize(userFluids))
    file:close()
    file = io.open("/home/NIDAS/settings/detectedFluids", "w")
    file:write(serialization.serialize(fluidsList))
    file:close()
    windowRefresh(searchKey.keyword)
    hud.updateFluidSettings()
end

local function load()
    local file = io.open("/home/NIDAS/settings/userFluids", "r")
    if file then
        userFluids = serialization.unserialize(file:read("*a")) or {}
        file:close()
        renderer.update()
    end
    file = io.open("/home/NIDAS/settings/detectedFluids", "r")
    if file then
        fluidsList = serialization.unserialize(file:read("*a")) or {}
        file:close()
        renderer.update()
    end
    file = io.open("/home/NIDAS/settings/fluidDisplaySettings", "r")
    if file then
        configurationData = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
end

local x = 18
local y = 1
local width = 50

local editorPage = nil
local refresh = nil

local function changeGlasses(glassAddress)
    selectedGlasses = glassAddress
    renderer.removeObject(editorPage)
    refresh()
    renderer.update()
    windowRefresh(searchKey.keyword)
end

local editorPages = {}
calls = 0
local function swapTableElements(glasses, a, b)
    calls = calls + 1
    if a ~= b and a > 0 and b > 0 and a <= #userFluids[selectedGlasses] and b <= #userFluids[selectedGlasses] then
        local copy = {}
        local e1 = nil
        local e2 = nil
        for k, v in pairs(userFluids[selectedGlasses]) do
            if k == a then
                e1 = v
            elseif k == b then
                e2 = v
            else
                copy[k] = v
            end
        end
        copy[b] = e1
        copy[a] = e2
        userFluids[selectedGlasses] = copy
        refresh()
        windowRefresh(searchKey.keyword)
    end
end

local function removeFluidFromGlasses(fluid)
    if userFluids[selectedGlasses] then
        local i = -1
        for j, f in pairs(userFluids[selectedGlasses]) do
            if fluid == f.id then
                i = j
            end
        end
        if i > 0 then
            local copy = userFluids[selectedGlasses]
            table.remove(copy, i)
            userFluids[selectedGlasses] = copy
            windowRefresh(searchKey.keyword)
            refresh()
        end
    end
end

local function stockingEditor()
    local context = graphics.context()
    local height = context.height-5
    if editorPages ~= nil then
        renderer.removeObject(editorPages)
    end
    editorPages = {}
    editorPage = gui.listFrame(x+width+1, 1, context.width - width - 2 - x, height, "Fluid Display")
    table.insert(editorPages, editorPage)

    context.gpu.setActiveBuffer(editorPage)
    graphics.text(3, 5, "User:", 0xFFFFFF)

    if selectedGlasses then
        local fluidsDisplayed = 0
        if userFluids[selectedGlasses] then
            for i, fluid in pairs(userFluids[selectedGlasses]) do
                context.gpu.setActiveBuffer(editorPage)
                graphics.text(5, 9 + 2*fluidsDisplayed, tostring(i)..":", gui.accentColor())

                local onActivation = {
                    {
                        displayName = "Remove from HUD",
                        value = removeFluidFromGlasses,
                        args = {fluid.id}
                    }
                }

                table.insert(editorPages, gui.smallButton(x + width + 8, 5 + fluidsDisplayed, fluid.name, gui.selectionBox, {x + width + 6, 5 + fluidsDisplayed, onActivation}, _, 0xFFFFFF, true))
                --graphics.text(8, 9 + 2*fluidsDisplayed, fluid.name, 0xFFFFFF)
                context.gpu.setActiveBuffer(0)
                table.insert(editorPages, gui.smallButton(context.width - 8, 5 + fluidsDisplayed, "⇧", swapTableElements, {selectedGlasses, i, i-1}, 3))
                table.insert(editorPages, gui.smallButton(context.width - 5, 5 + fluidsDisplayed, "⇩", swapTableElements, {selectedGlasses, i, i+1}, 3))
                fluidsDisplayed = fluidsDisplayed + 1
            end
        end
    end
    local onActivation = {}
    for address, componentType in component.list() do
        if componentType == "glasses" then
            local displayName = component.proxy(address).getBindPlayers() or address
            table.insert(onActivation, {displayName = displayName, value = changeGlasses, args = {address}})
        end
    end
    local displayName = selectedGlasses
    table.insert(editorPages, gui.smallButton(x+width+9, 3, displayName or "[ Select ]", gui.selectionBox, {x+56, y+2, onActivation}))
    context.gpu.setActiveBuffer(0)
    table.insert(editorPages, gui.bigButton(x+width+1, height+1, "Save Configuration", save, {}, context.width - width - 2 - x, false))

    renderer.update(editorPages)
end
refresh = stockingEditor

local function addFluidToGlasses(fluid)
    if userFluids[selectedGlasses] then
        if #userFluids[selectedGlasses] <= 20 then
            table.insert(userFluids[selectedGlasses], fluid)
        end
    else
        userFluids[selectedGlasses] = {}
        table.insert(userFluids[selectedGlasses], fluid)
    end
    windowRefresh(searchKey.keyword)
    refresh()
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

local idPages = nil
local levelPage = nil
local function displayPatterns(filterString)
    filterString = filterString or ""
    local context = graphics.context()
    local height = context.height-5
    maxEntries = height-3
    context.gpu.fill(x+1, y+1, width-2, height-2, " ")
    local function formCurrentView(fluids)
        if idPages ~= nil then
            renderer.removeObject(idPages)
        end
        local buttons = {}
        local i = 1
        for fluidID, fluidName in pairs(fluids) do
            local onActivation = {
                {
                    displayName = "Add to HUD",
                    value = addFluidToGlasses,
                    args = {{id=fluidID, name=fluidName}}
                }
            }
            if DEBUG then fluidName = fluidName .. " (" .. fluidID .. ")" end
            table.insert(
                buttons,
                {name = fluidName, func = gui.selectionBox, args = {x + 10, y + i, onActivation}}
            )
            i = i + 1
            if i > maxEntries then break end
        end
        idPages = gui.multiButtonList(x, y, buttons, width, height, "Available Fluids", colors.white, true)
        if levelPage == nil then
            levelPage = gui.listFrame(1, 1, x - 1, height, " ")
        end
        context.gpu.setActiveBuffer(levelPage)
        graphics.rectangle(2, 5, x-3, 2*(height)-6, colors.black)
        j = 1
        for fluidID, _ in pairs(fluids) do
            graphics.text(3, 3+j*2, "┅┅┅┅┅┅┅┅┅┅┅┅┅", fluidColors[fluidID] or gui.borderColor())
            j = j + 1
            if j > maxEntries then break end
        end
        local row = 5
        i = 1
        context.gpu.setActiveBuffer(0)
    end
    local function contains(fluidName)
        if userFluids[selectedGlasses] then
            for _, fluid in pairs(userFluids[selectedGlasses]) do
                if fluid.id == fluidName then
                    return true
                end
            end
        end
        return false
    end
    local nonSelectedFluids = {}
    for id, label in pairs(fluidsList) do
        if not contains(id) then
            nonSelectedFluids[id] = label
        end
    end
    local filteredFluids = filterByLabel(nonSelectedFluids, filterString)
    formCurrentView(filteredFluids)
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

local function discoverFluids(amount)
    amount = amount or 100000
    local context = graphics.context()
    local frame = gui.listFrame(context.width/2 - 11, context.height/2-3, 26, 4, "Discovering Fluids")
    renderer.update()
    local fluids = component.me_interface.getFluidsInNetwork()
    local total = #fluids
    context.gpu.setActiveBuffer(0)
    graphics.text(context.width/2 + 1, context.height-4, "/ "..tostring(total), gui.primaryColor())
    graphics.text(context.width/2 - #tostring(total), context.height-4, "_", gui.primaryColor())
    for _, fluid in pairs(fluids) do
        if type(fluid) == "table" then 
            fluidsList[fluid.name] = fluid.label
        end
    end
    renderer.removeObject(frame)
    context.gpu.fill(1, 1, context.width, context.height-2, " ")
    displayPatterns()

    renderer.update()
end

inView = false
local function returnToMenu()
    inView = false
    renderer.switchWindow("main")
    renderer.clearWindow("fluidDisplay")
    renderer.update()
end

local function displayView()
    inView = true
    load()
    local context = graphics.context()
    renderer.switchWindow("fluidDisplay")
    gui.smallButton(1, (context.height), "< < < Return", returnToMenu, {}, nil, gui.primaryColor())
    local divider = renderer.createObject(1, context.height - 1, context.width, 1)
    context.gpu.setActiveBuffer(divider)
    local bar = ""
    for i = 1, context.width do bar = bar .. "▂" end
    graphics.text(1, 1, bar, gui.borderColor())
    context.gpu.setActiveBuffer(0)
    if not initialized then
        discoverFluids() --Debug number
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

function fluidDisplay.windowButton()
    return {name = "Fluid Selector", func = displayView}
end

local function saveSettings()
    local file = io.open("/home/NIDAS/settings/fluidDisplaySettings", "w")
    if file then
        file:write(serialization.serialize(configurationData))
        file:close()
    end
end

function fluidDisplay.configure(configX, configY, _, _, _, page)
    local _, ySize = graphics.context().gpu.getBufferSize(page)
    graphics.context().gpu.setActiveBuffer(page)
    local configWindow = {}
    local attributeChangeList = {
        {name = "Name Scale (10-200)", attribute = "nameScale", type = "number", defaultValue = 70, minValue = 10, maxValue = 200},
        {name = "Amount Scale (10-200)", attribute = "amountScale", type = "number", defaultValue = 70, minValue = 10, maxValue = 200},
        {name = "Text Color (Hex)", attribute = "textColor", type = "color", defaultValue = 0x111111},
        {name = "Display Width", attribute = "displayWidth", type = "number", defaultValue = 50, minValue = 10, maxValue = 200},
        {name = "Bar Height", attribute = "barHeight", type = "number", defaultValue = 8, minValue = 1, maxValue = 100},
        {name = "Display Height Offset", attribute = "heightOffset", type = "number", defaultValue = 0, minValue = -50, maxValue = 2000},
    }
    gui.multiAttributeList(configX + 3, configY + 3, page, configWindow, attributeChangeList, configurationData)
    table.insert(configWindow, gui.bigButton(configX + 2, configY + tonumber(ySize) - 4, "Save Configuration", saveSettings))
    renderer.update()
    return configWindow
end

local lastKeyword = searchKey.keyword
local lastUser = selectedGlasses
function fluidDisplay.update(data)
    if inView and data ~= nil then
        graphics.context().gpu.setActiveBuffer(0)
    end
    if inView and (lastKeyword ~= searchKey.keyword) then
        displayPatterns(searchKey.keyword)
        lastKeyword = searchKey.keyword
    end
    if inView and ((lastUser ~= selectedGlasses) or updateFlag) then
        stockingEditor()
        lastUser = selectedGlasses
        updateFlag = false
        renderer.update()
    end
end

return fluidDisplay