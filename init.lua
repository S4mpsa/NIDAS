package.path = package.path..";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"
local drone = false
for address, name in pairs(require("component").list()) do
    if name == "navigation" then
        drone = true
        require("drone")
    end
end
if not drone then require("configuration") end