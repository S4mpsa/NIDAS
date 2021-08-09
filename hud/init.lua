-- Import section
local ar = require("lib.graphics.ar")
package.loaded.powerdisplay = nil
local powerDisplay = require("hud.powerdisplay")
local toolbar = require("hud.toolbar")
local component = require("component")
local serialization = require("serialization")
--

local glassData = {}

local function load()
    local file = io.open("/home/NIDAS/configuration/hudConfig", "r")
    if file ~= nil then
        glassData = serialization.unserialize(file:read("*a"))
        file:close()
    end
    if glassData == nil then glassData = {} end
end
local function save()
    local file = io.open("/home/NIDAS/configuration/hudConfig", "w")
    file:write(serialization.serialize(glassData))
    file:close()
end
local sampsaGlasses = component.proxy(component.get("a9676"))
local gordoGlasses = component.proxy(component.get("35227"))
local mattGlasses = component.proxy(component.get("da818b"))
local darkGlasses = component.proxy(component.get("dbd87"))

ar.clear(sampsaGlasses)
ar.clear(gordoGlasses)
ar.clear(mattGlasses)
ar.clear(darkGlasses)
local gordoAccent = math.floor(math.random() * 0xFFFFFF)
local gordoPrimary = math.floor(math.random() * 0xFFFFFF)

local hud = {}

local pages = {}
local selectedGlasses = "None"
local glassSelector = nil
local refresh = nil

local currentConfigWindow = {}
local function changeGlasses(glassAddress, data)
    selectedGlasses = glassAddress
    local x, y, gui, graphics, renderer, page = table.unpack(data)
    renderer.removeObject(currentConfigWindow)
    graphics.context().gpu.setActiveBuffer(page)
    refresh(x, y, gui, graphics, renderer, page)
end

function hud.configure(x, y, gui, graphics, renderer, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.text(3, 5, "Selected Glasses:")
    local onActivation = {}
    for address, componentType in component.list() do
        if componentType == "glasses" then
            if glassData[address] == nil then
                glassData[address] = {}
            end
            local displayName = glassData[address].owner or address
            table.insert(onActivation, {displayName = displayName, value = changeGlasses, args = {address, renderingData}})
        end
    end
    local _, ySize = graphics.context().gpu.getBufferSize(page)
    table.insert(currentConfigWindow, gui.smallButton(x+19, y+2, selectedGlasses, gui.selectionBox, {x+24, y+2, onActivation}))
    table.insert(currentConfigWindow, gui.bigButton(x+2, y+ySize-4, "Save Configuration", save))

    if selectedGlasses ~= "None" then
        local attributeChangeList = {
            {name = "Glass Owner",      attribute = "owner",    type = "string"},
            {name = "Resolution (X)",   attribute = "xRes",     type = "number"},
            {name = "Resolution (Y)",   attribute = "yRes",     type = "number"},
            {name = "Scale",            attribute = "scale",    type = "number"}
        }
        currentConfigWindow =  gui.multiAttributeList(x+3, y+3, page, attributeChangeList, glassData, selectedGlasses)
    end

    renderer.update()
    return currentConfigWindow
end
refresh = hud.configure

function hud.update(serverInfo)
    powerDisplay.widget({{sampsaGlasses, _, _, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, _, gordoPrimary, gordoAccent}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, 1, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, -4, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, -4, _, gordoPrimary, gordoAccent}})
end
load()
return hud
