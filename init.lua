-- Import section
local server = require("server")
local hud = require("hud")

--

local serverInfo
while true do
    serverInfo = server.update()
    hud.update(serverInfo)
    os.sleep(0)
end
