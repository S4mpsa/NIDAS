local component = require("component")

local gpu = component.gpu
local renderer = {}

function renderer.refresh()
    for _, window in ipairs(windowManager.getWindows()) do
        windowManager.draw(window)
        gpu.bitblt(0, window.position.x, window.position.y, window.size.x, window.size.y, window.buffer, 1, 1)
        end
    gpu.setActiveBuffer(0)
end

--Global refresh functions
function refresh(window, update)
    update = update or true
    if window then
        for _, windowCandidate in ipairs(windowManager.getWindows()) do
            if windowCandidate.name == window.name then
                if update then windowManager.draw(window) end
                gpu.bitblt(0, window.position.x, window.position.y, window.size.x, window.size.y, window.buffer, 1, 1)
                break
            end
        end
        gpu.setActiveBuffer(0)
    else
        renderer.refresh()
    end
end

return renderer