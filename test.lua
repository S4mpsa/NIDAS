local component = require("component")

--Window manager is global

local elements = require("core.graphics.elements.element")

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

local window = windowManager.create("Test Window 2", {x=50, y=30}, {x=40, y=10})
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

local function reboot()
    local shell = require("shell")
    shell.execute("reboot")
end

local rebootWindow = windowManager.create("Reboot", {x=8, y=3}, {x=2, y=42})
rebootWindow.addElements({
    elements.border(),
    elements.smallButton({x=2, y=2}, "Reboot", reboot, {}, true)
})

windowManager.initialize()

refresh()

while true do
    os.sleep(0.05)
end