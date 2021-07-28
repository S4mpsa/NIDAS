-- Import section
local ar = require("graphics.ar")
package.loaded.powerdisplay = nil
local powerDisplay = require("hud.powerdisplay")
local toolbar = require("hud.toolbar")
local component = require("component")
--

local sampsaGlasses = component.proxy(component.get("af55dfbf"))

local hud = {}

ar.clear(sampsaGlasses)

function hud.update(serverInfo)
    powerDisplay.widget({{sampsaGlasses}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3}})
end

return hud
