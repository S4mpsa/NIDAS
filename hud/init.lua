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
local function changeGlasses(glassAddress, data)
    selectedGlasses = glassAddress
    local x, y, gui, graphics, renderer, page = table.unpack(data)
    renderer.removeObject(pages)
    graphics.context().gpu.setActiveBuffer(page)
    refresh(x, y, gui, graphics, renderer, page)
end

function hud.configure(x, y, gui, graphics, renderer, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.text(3, 5, "Selected Glasses:")
    local availableGlasses = {}
    local onActivation = {}
    for address, componentType in component.list() do
        if componentType == "glasses" then
            table.insert(availableGlasses, address)
            table.insert(onActivation, {displayName = address, value = changeGlasses, args = {address, renderingData}})
        end
    end
    table.insert(pages, gui.smallButton(x+20, y+2, selectedGlasses, gui.selectionBox, {x+24, y+2, onActivation}))
    renderer.update()
    return pages
end
refresh = hud.configure

function hud.update(serverInfo)
    powerDisplay.widget({{sampsaGlasses, _, _, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, _, gordoPrimary, gordoAccent}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, 1, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, -4, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, -4, _, gordoPrimary, gordoAccent}})
end
load()
return hud
