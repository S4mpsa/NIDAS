local component = require("component")
local serialization = require("serialization")
local states         = require("server.entities.states")
local machineDisplay = {}

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")

local machineDisplayData = {}

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

local function returnToMenu()

end

local inView = false
local function displayView()
    inView = true
    renderer.setFocus()
end

gui.bigButton(40, graphics.context().height-4, "Machines", displayView)

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