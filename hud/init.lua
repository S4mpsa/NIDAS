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
local hud = {}

ar.clear(sampsaGlasses)
ar.clear(gordoGlasses)
ar.clear(mattGlasses)
local gordoAccent = math.floor(math.random() * 0xFFFFFF)
local gordoPrimary = math.floor(math.random() * 0xFFFFFF)

function hud.update(serverInfo)
    powerDisplay.widget({{sampsaGlasses}, {gordoGlasses, {1920, 1080}, 2, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, _, 0x0000FF, 0xFF0000}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3}, {gordoGlasses, {1920, 1080}, 2, -4, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, -4, _, 0x0000FF, 0xFF0000}})
end

return hud
