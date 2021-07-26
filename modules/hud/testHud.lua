--Test Values
package.path = package.path..";/NIDAS/lib/graphics/?.lua"..";/NIDAS/lib/utils/?.lua"..";/NIDAS/modules/hud/?.lua"
local component = require("component")
package.loaded.utility = nil
local util = require("utility")
local data = util.machine("53268277")
local ar = require("ar")
local colors = require("colors")
package.loaded.powerdisplay = nil
local powerDisplay = require("powerdisplay")
package.loaded.toolbar = nil
local toolbar = require("toolbar")

local glasses1 = util.machine("010717b2")
ar.clear(glasses1)

while true do 
    powerDisplay.widget({
        {glasses1}},
        data)
        toolbar.widget({{glasses1, _, _, 3}})
    os.sleep()

end