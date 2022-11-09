local frame = require('gui.frame')
local engine = require('core.lib.graphics.core.engine')

local function gui(centerComponent, navigationStack)
    while true do
        local page = frame(
            #navigationStack > 1,
            centerComponent,
            navigationStack[#navigationStack]
        )
        engine.render(page)
        engine.registerEvents(page)

        centerComponent = coroutine.yield()
    end
end

return gui
