-- Import section
local computer = require("computer")
--

local serverInfo

for _, v in pairs(computer.getDeviceInfo()) do
    if v.class == "system" then
        if v.description == "Tablet" then
            local tablet = require("tablet")
        else
            local server = require("server")
            local hud = require("hud")
            local powerControl = require("modules.tools.powerControl")
            while true do
                serverInfo = server.update()
                hud.update(serverInfo)
                powerControl(serverInfo.power, "b8583fd9")
                os.sleep(0)
            end
        end
        break
    end
end
