local altarWidget = require('modules.infusion.gui.altar-widget')
local render = require('core.lib.graphics.core.engine').render

local infusionCoroutine = coroutine.create(function(...)
    local args = ...
    while true do
        local widget = altarWidget(args[2], args[3], args[4], args[5])
        render(widget)
        args = coroutine.yield()
    end
end)

return { 'Infusion automation', infusionCoroutine }
