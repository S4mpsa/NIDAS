local event = require("event")
local w = require("core.graphics.renderer.window")
local contextMenu = require("core.graphics.ui.contextMenu")
local elements = require("core.graphics.elements.element")

local gpu = require("component").gpu

local windowManager = {}

local windows = {}
local tabs = {}
local activeTab = nil
local toolbar
local toolbarShown = true

---@param name string
---@param size Coordinate2D
---@param position Coordinate2D
function windowManager.create(name, size, position)
    local window = w.create(name, size, position)
    windowManager.attach(window)
    return window
end

function windowManager.clear()
    gpu.fill(0, 0, 160, 50, " ")
end

function windowManager.draw(update)
    return w.draw(update)
end

---@param window Window
function windowManager.attach(window)
    table.insert(windows[activeTab], window)
end

function windowManager.detach(window)
    --Check that windowManager has initialized
    if windows[activeTab] then
        for i, candidate in ipairs(windows[activeTab]) do
            if window.name == candidate.name then
                table.remove(windows[activeTab], i)
                return
            end
        end
    end
end

function windowManager.getWindows()
    return windows[activeTab]
end

local function checkClick(window, x, y)
    if (y >= window.position.y - 1 and y < window.position.y + window.size.y)
    and (x >= window.position.x and x < window.position.x + window.size.x) then
        return true
    else
        return false
    end
end

local function toggleToolbar()
    if toolbarShown then
        windowManager.detach(toolbar)
        local x, y = gpu.getResolution()
        gpu.fill(1, y-1, x, 2, " ")
        toolbarShown = false
    else
        windowManager.attach(toolbar)
        refresh(toolbar)
        toolbarShown = true
    end
end

---Switches to or creates a new tab without rendering
---@param name string
function windowManager.setActiveTab(name)
    if windows[name] then
        windowManager.detach(toolbar)
        activeTab = name
    else
        windows[name] = {}
        table.insert(tabs, name)
        windowManager.detach(toolbar)
        activeTab = name
    end
    windowManager.attach(toolbar)
end

function windowManager.getActiveTab()
    return activeTab
end

function windowManager.getTabs()
    return tabs
end

---Switch to an existing tab and render it
---@param name string
function windowManager.switchToTab(name)
    if windows[name] then
        windowManager.detach(toolbar)
        activeTab = name
        windowManager.attach(toolbar)
        windowManager.clear()
        refresh()
    else
        error("No Tab [" .. name .. "] found.")
    end
end

--Pass clicks to the relevant windows
local function onClick(eventName, address, x, y, button, name)
    for i = #windows[activeTab], 1, -1 do
        if checkClick(windows[activeTab][i], x, y) then
            windows[activeTab][i].onClick(windows[activeTab][i], eventName, address, x, y, button, name)
            return
        end
    end
    --Handle off-window clicks
    if button == 1 and eventName == "touch" then
        if toolbarShown then
            contextMenu(nil, {{name = "Hide toolbar", func = toggleToolbar}}, x, y)
        else
            contextMenu(nil, {{name = "Show toolbar", func = toggleToolbar}}, x, y)
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
function windowManager.init()
    stopClickHandler()
    startClickHandler()
    local x, y = 120, 34
    gpu.fill(1, 1, x, y, " ")
    gpu.setResolution(x, y)
    toolbar = w.create("Toolbar", {x=x, y=2}, {x=1, y=y-1}).addElement(elements.toolbar())
    logoWindow = w.create("LogoWindow", {x=27, y=7}, {x = x - 28, y=y - 8}).addElement(elements.logoLarge({1, 1}))
    windowManager.setActiveTab("Home")
    windowManager.attach(logoWindow)

end

function windowManager.pause()
    stopClickHandler()
end

function windowManager.resume()
    startClickHandler()
end

return windowManager