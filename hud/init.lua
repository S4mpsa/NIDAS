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

function hud.update(serverInfo)
    powerDisplay.widget({{sampsaGlasses}, {gordoGlasses, {1920, 1080}}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3}, {gordoGlasses, {1920, 1080}, _, -4}})
end

return hud
