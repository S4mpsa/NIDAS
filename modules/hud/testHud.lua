--Test Values
package.path = package.path..";/NIDAS/lib/graphics/?.lua"..";/NIDAS/lib/utils/?.lua"..";/NIDAS/modules/hud/?.lua"
local component = require("component")
local util = require("utility")
local data = util.machine("53268277")
local ar = require("ar")
local colors = require("colors")
package.loaded.powerdisplay = nil
local powerDisplay = require("powerdisplay")

local glasses1 = util.machine("010717b2")
local glasses2 = util.machine("f7c85e42")
local glasses3 = 1
ar.clear(glasses1)
ar.clear(glasses2)
local count = 1
while count < 50 do 
    powerDisplay.widget({
        {glasses1, {2560, 1440}, 3, 337, 29},
        {glasses2}},
        data)
    os.sleep()
    count = count + 1
    
end

powerDisplay.remove()