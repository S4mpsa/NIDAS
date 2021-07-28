-- Import section
local glasses = require("component").glasses
local ar = require("graphics.ar")
local powerDisplay = require("hud.powerdisplay")
local toolbar = require("hud.toolbar")

--

local hud = {}

ar.clear(glasses)

function hud.update(serverInfo)
    powerDisplay.widget({{glasses}}, serverInfo.power)
    toolbar.widget({{glasses}})
end

return hud
