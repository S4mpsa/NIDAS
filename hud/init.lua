-- Import section
local ar = require("graphics.ar")
package.loaded.powerdisplay = nil
local powerDisplay = require("hud.powerdisplay")
local toolbar = require("hud.toolbar")
local component = require("component")
--

local sampsaGlasses = component.proxy(component.get("af55dfbf"))
local gordoGlasses = component.proxy(component.get("27f3251b"))
local mattGlasses = component.proxy(component.get("bb4ce7cd"))
local darkGlasses = component.proxy(component.get("60155261"))
local hud = {}

ar.clear(sampsaGlasses)
ar.clear(gordoGlasses)
ar.clear(mattGlasses)
ar.clear(darkGlasses)
local gordoAccent = math.floor(math.random() * 0xFFFFFF)
local gordoPrimary = math.floor(math.random() * 0xFFFFFF)

function hud.update(serverInfo)
    powerDisplay.widget({{sampsaGlasses, _, _, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, _, gordoPrimary, gordoAccent}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, 1, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, -4, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, -4, _, gordoPrimary, gordoAccent}})
end

return hud
