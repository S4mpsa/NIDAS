-- Adds NIDAS library folders to default package path
package.path = package.path .. ";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"
--Require global libraries
windowManager = require("core.graphics.renderer.windowManager")
glassManager = require("core.ar.renderer.glassManager")
moduleManager = require("core.modules.moduleManager")
componentManager = require("core.network.componentManager")
nodeManager = require("core.network.nodeManager")
contextMenu = require("core.graphics.ui.contextMenu")
renderer = require("core.graphics.renderer.renderer")
theme = require("settings.theme")
settings = require("settings.settings")
local serialization = require("serialization")
local dataUtils = require("core.lib.data")
machineNames = dataUtils.load("machineNames") or {}
terminalPositions = dataUtils.load("terminalPositions") or {}

local elements = require("core.graphics.elements.element")

function nidasError(errorMessage)
    windowManager.setActiveTab("Errors")
    local errorWindow = windowManager.create("ErrorWindow", {x=140, y=45}, {x=2, y=2}).addElement(
    elements.errorMessage({x=0, y=0}, {x=140, y=45}, errorMessage))
    windowManager.switchToTab("Errors")
end

function catch(func, ...)
    local success, ret = xpcall(func, debug.traceback, table.unpack(...))
    if not success then
        nidasError(ret)
    else
        return ret
    end
end

if require("component").modem then
    nodeManager.init()
end

--Dev function, this should not be here
function listen()
    while true do print(require("event").pull()); os.sleep() end
end

windowManager.init()
glassManager.init()
componentManager.init()
require("shell").execute("test.lua")