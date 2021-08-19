package.path = package.path .. ";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"
local drone = false
for _, name in pairs(require("component").list()) do
    if name == "navigation" then
        drone = true
        local gpu = require("component").gpu
        gpu.setResolution(gpu.maxResolution())
        require("drone")
        break
    end
end
if not drone then
    require("configuration")
end
