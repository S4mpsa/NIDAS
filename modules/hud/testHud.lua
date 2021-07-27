package.path = package.path..";/NIDAS/lib/graphics/?.lua"..";/NIDAS/lib/utils/?.lua"..";/NIDAS/modules/hud/?.lua"
local component = require("component")
local ar = require("ar")
local powerDisplay = require("powerdisplay")
local toolbar = require("toolbar")

local glasses = component.glasses
local data = component.gt_machine
ar.clear(glasses)

while true do 
    powerDisplay.widget({
        {glasses}},
        data)
    toolbar.widget({{glasses}})
    os.sleep()
end