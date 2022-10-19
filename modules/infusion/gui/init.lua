local altarDashboard = require('modules.infusion.gui.altar-dashboard')
local render = require('core.lib.graphics.core.engine').render

local infusionGuiCoroutine = coroutine.create(function(...)
    local args = { ... }
    while true do
        table.remove(args, 1)
        local dashboard = altarDashboard(table.unpack(args))
        render(dashboard)
        args = { coroutine.yield() }
    end
end)

return { 'Infusion automation GUI', infusionGuiCoroutine }
