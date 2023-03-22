local event = require("event")
local w = require("core.graphics.renderer.window")
local contextMenu = require("core.graphics.ui.contextMenu")

local windowManager = {}

local windows = {}

---@param name string
---@param size Coordinate2D
---@param position Coordinate2D
function windowManager.create(name, size, position)
    local window = w.create(name, size, position)
    windowManager.attach(window)
    return window
end

function windowManager.update(update)
    return w.update(update)
end

---@param window Window
function windowManager.attach(window)
    table.insert(windows, window)
end

function windowManager.detach(window)
    for i, candidate in ipairs(windows) do
        if window.name == candidate.name then
            table.remove(windows, i)
            return
        end
    end
end

function windowManager.getWindows()
    return windows
end

local function checkClick(window, x, y)
    if (y >= window.position.y and y < window.position.y + window.size.y)
    and (x >= window.position.x and x < window.position.x + window.size.x) then
        return true
    else
        return false
    end
end

--Pass clicks to the relevant windows
local function onClick(eventName, address, x, y, button, name)
    for i = #windows, 1, -1 do
        if checkClick(windows[i], x, y) then
            windows[i].onClick(windows[i], eventName, address, x, y, button, name)
            break
        end
    end
end

local function startClickHandler()
    event.listen("touch", onClick)
    event.listen("drag", onClick)
end

local function stopClickHandler()
    event.ignore("touch", onClick)
end

--Clear out existing click handlers
function windowManager.initialize()
    stopClickHandler()
    startClickHandler()
end

function windowManager.pause()
    stopClickHandler()
end

function windowManager.resume()
    startClickHandler()
end

return windowManager