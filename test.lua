local component = require("component")

--Window manager is global

local machineDisplay = require("core.modules.sampsa.machineDisplay")
local hudConfigurator = require("core.modules.sampsa.hudConfigurator")
elements = require("core.graphics.elements.element")
hudElements = require("core.ar.hud.hudElement")
local worldElements = require("core.ar.world.worldElement")
local gpu = component.gpu


function log(str)
    local x, y = gpu.getResolution()
    gpu.set(0, y, str)
end

function logClick()
    local x, y = gpu.getResolution()
    gpu.set(0, y-2, "An option was executed.")
end

function writeOnScreen(str)
    gpu.setForeground(0xFFFFFF)
    gpu.setActiveBuffer(0)
    gpu.set(0, 45, str)
end

gpu.fill(0, 0, 160, 50, " ")

local tab = windowManager.getActiveTab()
windowManager.setActiveTab("Test Tab")

local window = windowManager.create("Test Window 2", {x=50, y=20}, {x=5, y=3})
window.addElements({
    elements.border(),
    elements.title(),
    elements.closeButton(),
    elements.singleLineText({x=3, y = 3}, "Text Input"),
    elements.textField({x=20, y = 3}, "Text", 15),
    elements.singleLineText({x=3, y = 4}, "Number Input"),
    elements.numberField({x=20, y=4}, 25.0, 15),
    elements.singleLineText({x=3, y = 6}, "Slider Input"),
    elements.slider({x=20, y = 5}, {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100}, 3, 15),
    elements.singleLineText({x=3, y = 7}, "On/Off Input"),
    elements.checkbox({x=20, y=7}, true),
    elements.singleLineText({x=3, y = 8}, "Small Button"),
    elements.smallButton({x=20, y = 8}, "Click me!", writeOnScreen, {"Argument"}, true),
    elements.singleLineText({x=3, y = 10}, "Large Button"),
    elements.largeButton({x=20, y = 9}, "Click me!", writeOnScreen, {"Argument"}, true),
    elements.singleLineText({x=3, y = 12}, "Colour Selector"),
    elements.colourSelector({x=20, y = 12}, theme.primaryColour)
                        })
window.setOptions({
    {name = "Context Menu 1", func = logClick},
    {name = "Context Menu 2", func = logClick},
    {name = "Context Menu 3", func = logClick}
})
window.enableMovement()

windowManager.setActiveTab("Empty Tab")
windowManager.setActiveTab("Errors")
windowManager.setActiveTab("Home")

local welcomeWindow = windowManager.create("WelcomeWindow", {x=50, y=20}, {x=2, y=2}).addElement(
    elements.multiLineText({x=0, y=0}, {x=50, y=20}, "Welcome to NIDAS 2.0! This is an in-development version. Expect bugs and missing features."))

windowManager.switchToTab("Home")

--local worldObject = glassManager.createObject("Sampsa_", "Test Cube", {x=1, y=1, z=1})
--worldObject.addElement(worldElements.cube({x=0, y=0, z=0}, 1.5, 0x22FFAA, 0.8))

--machineDisplay.init()

moduleManager.attach(hudConfigurator())

glassManager.render()

moduleManager.init()