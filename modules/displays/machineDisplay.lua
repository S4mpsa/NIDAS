local component = require("component")
local serialization = require("serialization")
local states         = require("server.entities.states")
local machineDisplay = {}
local event = require("event")

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")

local machineDisplayData = {}
local bufferPages = {}

local function save(data)
    local file = io.open("/home/NIDAS/settings/machineDisplayData", "w")
    file:write(serialization.serialize(machineDisplayData))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/machineDisplayData", "r")
    if file then
        machineDisplayData = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
end
-- Set up window changing


local inView = false
local displayListener = nil
local keyboardListener = nil

local function returnToMenu()
    inView = false
    event.cancel(displayListener)
    renderer.removeObject(bufferPages)
    renderer.leaveFocus()
    graphics.clear()
    renderer.update()
end

local function checkClick(_, _, X, Y)
    if X >= 1 and X < 13 and Y == graphics.context().height then
        returnToMenu()
    end
end
local function checkButton(_, _, char, code, player)
    if char == 114 then
        returnToMenu()
    end
end

local function displayView()
    inView = true
    renderer.setFocus()
    graphics.clear()
    graphics.text(1, (graphics.context().height * 2) - 1, "< < < Return", gui.primaryColor())
    local divider = ""
    for i = 1, graphics.context().width do divider = divider .. "▂" end
    graphics.text(1, (graphics.context().height * 2) - 1, "< < < Return", gui.primaryColor())
    graphics.text(1, (graphics.context().height * 2) - 3, divider, gui.borderColor())
    displayListener = event.listen("touch", checkClick)
end

gui.bigButton(40, graphics.context().height-4, "Machines", displayView, _, _, true)

local refresh = nil
local currentConfigWindow = {}
function machineDisplay.configure(x, y, _, _, _, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.context().gpu.setActiveBuffer(page)
    renderer.update()
    return currentConfigWindow
end
refresh = machineDisplay.configure

load()

function machineDisplay.update(data)
    if inView then
        
    end
end

return machineDisplay