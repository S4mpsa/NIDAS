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
                require("robot")
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
