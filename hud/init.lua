-- Import section
local ar = require("graphics.ar")
package.loaded.powerdisplay = nil
local powerDisplay = require("hud.powerdisplay")
local toolbar = require("hud.toolbar")
local component = require("component")
--

local sampsaGlasses = component.proxy(component.get("a9676"))
local gordoGlasses = component.proxy(component.get("7be3967"))
local mattGlasses = component.proxy(component.get("bcc32e"))
local darkGlasses = component.proxy(component.get("f9b8d3"))

ar.clear(sampsaGlasses)
ar.clear(gordoGlasses)
ar.clear(mattGlasses)
ar.clear(darkGlasses)
local gordoAccent = math.floor(math.random() * 0xFFFFFF)
local gordoPrimary = math.floor(math.random() * 0xFFFFFF)

local function update(serverInfo)
    powerDisplay.widget({{sampsaGlasses, _, _, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, _, gordoPrimary, gordoAccent}}, serverInfo.power)
    toolbar.widget({{sampsaGlasses, _, _, 3, _, gordoPrimary, gordoAccent}, {darkGlasses, _, _, 1, _, gordoPrimary, gordoAccent}, {gordoGlasses, {1920, 1080}, 2, -4, _, gordoPrimary, gordoAccent}, {mattGlasses,  {1210, 1004}, 2, -4, _, gordoPrimary, gordoAccent}})
end

return update
