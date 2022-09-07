-- Adds NIDAS library folders to default package path
package.path = package.path .. ";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"

-- local modules = { require("modules.infusion.init") }
-- while true do
--     for name, coro in pairs(modules) do
--         local status, result = coroutine.resume(coro)
--         if not status then
--             print("Error on module " .. name .. ": " .. result)
--         end
--     end
-- end

require("modules.infusion.init")
