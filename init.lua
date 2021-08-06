-- Import section
local server = require("server")
local hud = require("hud")
local event = require("event")
local powerControl = require("modules.tools.powerControl")
local moduleSelection = require("configuration.modules")
--

local serverInfo

while true do
    serverInfo = server.update()
    if moduleSelection.hud then hud.update(serverInfo) end
    if moduleSelection.powerControl then powerControl(serverInfo.power, "b8583fd9") end
    os.sleep()
end
