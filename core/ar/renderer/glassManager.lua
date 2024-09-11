local event = require("event")
local component = require("component")
local data = require("core.lib.data")
local hud = require("core.ar.renderer.hudWindow")
local worldObject = require("core.ar.renderer.worldObject")
local elements = require("core.graphics.elements.element")
local glassManager = {}

local windows = {}
local worldObjects = {}
local players = {}
local resolutions = {}
local activePlayer = nil

---Data handling---------------------------------------------------------------

local function save()
    data.save("resolutions", resolutions)
end

local function load()
    resolutions = data.load("resolutions")
    if not resolutions then --No saved data
        resolutions = {}
    end
end

---Window handling-------------------------------------------------------------

---Creates a window on the player HUD
---@param player string
---@param name string
---@param size Coordinate2D
---@param position Coordinate2D
function glassManager.create(player, name, size, position)
    if player then
        local window = hud.create(player, name, size, position)
        glassManager.attach(window, onTop)
        return window
    else
        error("No glass owner has been given!")
    end
end

---Creates a 3D anchor point with absolute world coordinates
---@param player string
---@param name string
---@param position Coordinate3D
function glassManager.createObject(player, name, position)
    if player then
        local object = worldObject.create(player, name, position)
        glassManager.attachObject(object)
        return object
    else
        error("No glass owner has been given!")
    end
end

---Attaches a window to the player's HUD
---@param window Window
function glassManager.attach(window)
    table.insert(windows[activePlayer], window)
end

function glassManager.attachObject(object)
    table.insert(worldObjects[activePlayer], object)
end

function glassManager.detach(window)
    --Check that glassManager has initialized
    local oldActivePlayer = activePlayer
    activePlayer = window.owner
    if windows[activePlayer] then
        for i, candidate in ipairs(windows[activePlayer]) do
            if window.name == candidate.name then
                table.remove(windows[activePlayer], i)
                return
            end
        end
    end
    activePlayer = oldActivePlayer
end

---Clears all widgets. Optionally only clears widgets from a single player
---@param player? string
local function clearAllWidgets(player)
    if player then
        for address, _ in pairs(component.list("glasses")) do
            local glasses = component.proxy(address)
            if glasses.getBindPlayers() == player then
                if glasses then
                    glasses.removeAll()
                end
            end
        end
    else
        for address, _ in pairs(component.list("glasses")) do
            local glasses = component.proxy(address)
            if glasses then
                glasses.removeAll()
            end
        end
    end
end

function glassManager.render(container)
    if container then
        for _, hudWindows in pairs(windows) do
            for _, window in ipairs(hudWindows) do
                if window.name == container.name then
                    window.init();
                end
            end
        end
        for _, objects in pairs(worldObjects) do
            for _, object in ipairs(objects) do
                if object.name == container.name then
                    object.init();
                end
            end
        end
    else
        clearAllWidgets()
        for _, hudWindows in pairs(windows) do
            for _, window in ipairs(hudWindows) do
                window.init();
            end
        end
        for _, objects in pairs(worldObjects) do
            for _, object in ipairs(objects) do
                object.init();
            end
        end
    end
end

---Getters and setters------------------------------------------------------

---Switches to or creates a new tab without rendering
---@param name string
function glassManager.setActivePlayer(name)
    if windows[name] and worldObjects[name] then
        activePlayer = name
    else
        if not windows[name] then
            windows[name] = {}
        end
        if not worldObjects[name] then
            worldObjects[name] = {}
        end
        table.insert(players, name)
        activePlayer = name
    end
end

function glassManager.getGlassProxy(name)
    for address, _ in pairs(component.list("glasses")) do
        local glasses = component.proxy(address)
        if glasses then
            local owner = glasses.getBindPlayers()
            if owner == name then return glasses end
        end
    end
    return nil
end

function glassManager.getActivePlayer() return activePlayer end

function glassManager.getPlayers() return players end

function glassManager.getWindows() return windows[activePlayer] end

function glassManager.getResolution(player) return resolutions[player] or {x=0, y=0} end

---User input handling----------------------------------------------------------------

local function checkClick(window, x, y)
    if (y >= window.position.y - 1 and y < window.position.y + window.size.y)
    and (x >= window.position.x and x < window.position.x + window.size.x) then
        return true
    else
        return false
    end
end

local lastActiveWindow = nil
local function onClick(eventName, address, name, x, y, button)
    local previousActive = activePlayer
    glassManager.setActivePlayer(name)
    local handled = false
    for i = #windows[activePlayer], 1, -1 do
        if checkClick(windows[activePlayer][i], x, y) then
            lastActiveWindow = windows[activePlayer][i]
            if windows[activePlayer][i].onClick ~= nil then
                handled = catch(windows[activePlayer][i].onClick, table.pack(windows[activePlayer][i], eventName, address, x, y, button, name))
            else
                nidasError("Window [" .. windows[activePlayer][i].name .. "] had no onClick function!")
            end
            activePlayer = previousActive
            if handled then return end
        end
    end
    --Handle off-window clicks
    if eventName == "hud_drag" and lastActiveWindow then
        handled = catch(lastActiveWindow.onClick, table.pack(lastActiveWindow, eventName, address, x, y, button, name))
    else
        lastActiveWindow = nil
        activePlayer = previousActive
        if handled then return end
    end
    activePlayer = previousActive
end

local function onInteract(eventName, address, name, x, y, z, side)
    for player, objects in pairs(worldObjects) do
        for _, object in ipairs(objects) do
            if player == name and (object.position.x == x and object.position.y == y and object.position.z == z) then
                catch(object.interact, table.pack(object, name, side))
            end
        end
    end
end

local function onClose(eventName, address, name)
    if windows[name] then
        for i, window in ipairs(windows[name]) do
            if window.options.closeOnFocusLoss then
                window.remove()
            end
        end
    end
end

local function registerUsers(eventName, address, name, x, y)
    resolutions[name] = {x=x, y=y}
    save()
end

local function startClickHandler()
    event.listen("hud_click", onClick)
    event.listen("hud_drag", onClick)
    event.listen("block_interact", onInteract)
    event.listen("overlay_closed", onClose)
end

local function stopClickHandler()
    event.ignore("hud_click", onClick)
    event.ignore("hud_drag", onClick)
    event.ignore("block_interact", onInteract)
    event.ignore("overlay_closed", onClose)
end

--Clear out existing click handlers
function glassManager.init()
    load()
    clearAllWidgets()

    event.listen("glasses_on", registerUsers)

    stopClickHandler()
    startClickHandler()
end

function glassManager.pause()
    stopClickHandler()
end

function glassManager.resume()
    startClickHandler()
end

return glassManager