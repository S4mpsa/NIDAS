<<<<<<< Updated upstream
package.path = package.path .. ";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"
local robot = false
for _, part in pairs(require("computer").getDeviceInfo()) do
    if part.class == "system" and part.description == "Robot" then
        robot = true
        local navigation = false
        for _, component in pairs(require("component").list()) do
            if component == "navigation" then
                navigation = true
                local gpu = require("component").gpu
                gpu.setResolution(gpu.maxResolution())
                require("location-robot")
                break
            end
        end
        if not navigation then
            print("Navigation upgrade not installed!")
            print("Please put and upgrade in the slot.")
        end
        break
    end
end
if not robot then
    require("configuration")
end
=======
-- Adds NIDAS library folders to default package path
package.path = package.path .. ";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"
--Require global libraries
windowManager = require("core.graphics.renderer.windowManager")
contextMenu = require("core.graphics.ui.contextMenu")
renderer = require("core.graphics.renderer.renderer")
theme = require("settings.theme")
>>>>>>> Stashed changes
