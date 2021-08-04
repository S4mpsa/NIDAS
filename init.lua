-- Import section
local server = require("server")
local hud = require("hud")
local event = require("event")
local powerControl = require("modules.tools.powerControl")
--

local serverInfo

while true do
    serverInfo = server.update()
    hud.update(serverInfo)
    powerControl(serverInfo.power, "b8583fd9")
    os.sleep()
end