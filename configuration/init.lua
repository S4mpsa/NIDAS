local menu = require("configuration.menu")
local c = require("component")
--Automatic rebooting
if #c.list("redstone") > 0 then
    c.redstone.setWakeThreshold(1)
end

menu()
