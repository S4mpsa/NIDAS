local component = require("component")
local serialization = require("serialization")
local transforms = require("transforms")
local states         = require("server.entities.states")
local colors         = require("graphics.colors")
local machineDisplay = {}

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")

local interface = component.me_interface
craftablesList = {}
stockingLevels = {}
local currentConfigWindow = {}
local function save()
    local file = io.open("/home/NIDAS/settings/stockingLevels", "w")
    file:write(serialization.serialize(stockingLevels))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/stockingLevels", "r")
    if file then
        local stockingLevels = serialization.unserialize(file:read("*a")) or {}
        file:close()
        renderer.update()
    end
end

local activePattern = ""
local function changeActivePattern(patternName)
    activePattern = patternName
end

function filterByLabel(data, keyword)
    local filtered = {}
    for i = 1, #data, 1 do
        if string.find(data[i].label, keyword) ~= nil then
            table.insert(filtered, 1, data[i])
        end
    end
    return filtered
end

local function sortByStockLevel(data, stocklevels)

end

local x = 1
local y = 1
local width = 50

local idPages = nil
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
        for i = 1, #patterns do
            local onActivation = {
                {
                    displayName = "Edit Stocking Level",
                    value = changeActivePattern,
                    args = {patterns[i].label}
                }
            }
            table.insert(
                buttons,
                {name = patterns[i].label, func = gui.selectionBox, args = {x + width / 2, y + i, onActivation}}
            )
        end
        idPages = gui.multiButtonList(x, y, buttons, width, height, "Patterns", colors.white, true)
    end
    context.gpu.setActiveBuffer(0)
    local filteredPatterns = filterByLabel(craftablesList, filterString)
    formCurrentView(transforms.sub(filteredPatterns, 1, maxEntries))
    renderer.update()
end

searchKey = {keyword = "Im fag"}
local function searchBox()
    local context = graphics.context()
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
    graphics.text(x, context.height*2-9, top, gui.primaryColor())
    graphics.text(x, context.height*2-7, middle, gui.primaryColor())
    graphics.text(x, context.height*2-5, bottom, gui.primaryColor())
    gui.multiAttributeList(x+1, context.height-4, 0, currentConfigWindow, {{name = "Search: ", attribute = "keyword", type = "string", defaultValue = ""}}, searchKey, nil, 38)
end

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
            table.insert(craftablesList, 1, {label = craftable.getItemStack().label, request = craftable.request})
        end
        if i == amount then
            graphics.text(context.width/2 - 5, context.height-4, "DEBUG", gui.accentColor())
            break
        end
    end
    renderer.removeObject(frame)
    context.gpu.fill(1, 1, context.width, context.height-2, " ")
    displayPatterns()
    searchBox()
    renderer.update()
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
    local context = graphics.context()
    renderer.switchWindow("autostocker")
    gui.smallButton(1, (context.height), "< < < Return", returnToMenu, {}, nil, gui.primaryColor())
    local divider = renderer.createObject(1, context.height - 1, context.width, 1)
    context.gpu.setActiveBuffer(divider)
    local bar = ""
    for i = 1, context.width do bar = bar .. "▂" end
    graphics.text(1, 1, bar, gui.borderColor())
    context.gpu.setActiveBuffer(0)
    if #craftablesList == 0 then
        discoverPatterns(100) --Debug number
    else
        displayPatterns()
    end
    renderer.update()
end

function machineDisplay.windowButton()
    return {name = "Autostocker", func = displayView}
end
--gui.bigButton(40, graphics.context().height-4, "Machines", displayView, _, _, true)


function machineDisplay.configure(x, y, _, _, _, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.context().gpu.setActiveBuffer(page)
    renderer.update()
    return currentConfigWindow
end

local lastKeyword = searchKey.keyword
function machineDisplay.update(data)
    if inView and data ~= nil then
        graphics.context().gpu.setActiveBuffer(0)
    end
    if lastKeyword ~= searchKey.keyword then
        displayPatterns(searchKey.keyword)
        lastKeyword = searchKey.keyword
    end
end

return machineDisplay