local frame = require('gui.frame')
local render = require('core.lib.graphics.core.engine').render

local function gui(title, centerComponent)
    while true do
        local page = frame(title, centerComponent)
        render(page)
        coroutine.yield()
    end
end

return gui
