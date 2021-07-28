-- Import section
local ar = require("graphics.ar")
package.loaded.powerdisplay = nil
local powerDisplay = require("hud.powerdisplay")
local toolbar = require("hud.toolbar")
local component = require("component")
--

local sampsaGlasses = component.proxy(component.get("af55dfbf"))
local gordoGlasses = component.proxy(component.get("27f3251b"))
local hud = {}

ar.clear(sampsaGlasses)
ar.clear(gordoGlasses)
local gordoAccent = math.floor(math.random() * 0xFFFFFF)
local gordoPrimary = math.floor(math.random() * 0xFFFFFF)

function hud.update(serverInfo)
    powerDisplay.widget({{sampsaGlasses}, {gordoGlasses, {1920, 1080}, 2, 389, _, _, gordoPrimary, gordoAccent}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3}, {gordoGlasses, {1920, 1080}, 2, -4, _, gordoPrimary, gordoAccent}})
end

return hud
