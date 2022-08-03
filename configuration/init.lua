local menu = require("configuration.menu")
local redstone = require("component").redstone
if redstone then
    redstone.setWakeThreshold(1)
end
menu()
