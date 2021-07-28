-- Import section
local glasses = require("component").glasses
local ar = require("ar")
local powerDisplay = require("powerdisplay")
local toolbar = require("toolbar")

--

local hud = {}

ar.clear(glasses)

function hud.update(serverInfo)
    powerDisplay.widget({{glasses}}, serverInfo.power)
    toolbar.widget({{glasses}})
end

return hud
