local menu = require("configuration.menu")
local redstone = require("component").redstone
--Automatic rebooting
if redstone then
    redstone.setWakeThreshold(1)
end

menu()
