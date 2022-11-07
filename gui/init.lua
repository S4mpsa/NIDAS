local frame = require('gui.frame')
local engine = require('core.lib.graphics.core.engine')

local function gui(title, centerComponent)
    while true do
        local page = frame(title, centerComponent)
        engine.render(page)
        engine.registerEvents(page)

        coroutine.yield()
    end
end

return gui
