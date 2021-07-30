local renderer = require("renderer")
package.loaded.graphics = nil
local graphics = require("graphics")
package.loaded.gui = nil
local gui      = require("gui")
local component = require("component")
local colors    = require("colors")
local event = require("event")
local testObject = {
    gpu = component.gpu,
    page = 0,
    x = 0,
    y = 0,
    width = 160,
    heigth = 50,
    state = 0,
    clickable = false,
    clickArea = {{0, 0}, {0, 0}},
    clickFunction = nil,
    boundScreens = 0

}
graphics.setContext(testObject)
graphics.clear()

local listener = 0

local function changeBackground(_, _, X, Y, button)
    event.cancel(listener)
    local color = gui.colorSelection(X, Y, colors)
    if color ~= nil then
        graphics.rectangle(50, 17, 30, 30, color)
    end
    listener = event.listen("touch", changeBackground)
end

local function greenBox()
    graphics.rectangle(10, 10, 10, 10, colors.green)
end

local function redBox()
    graphics.rectangle(10, 10, 10, 10, colors.red)
end

local strings = {{displayName = "Hello!", value = greenBox},
                {displayName = "Greetings!", value = redBox}
}
local function choose(_, _, X, Y, button)
    event.cancel(listener)
    local string = gui.selectionBox(X, Y, strings)
    if string ~= nil then
        string()
    end
    listener = event.listen("touch", choose)
end

listener = event.listen("touch", choose)
