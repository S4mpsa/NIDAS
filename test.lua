graphics = require("core.graphics.graphics")
manager = require("core.graphics.windowmanager")
renderer = require("core.graphics.renderer")
local gui = require("core.graphics.gui")

local i = 1

local function testConstuctor(windowName, text)
    local window = manager.getWindow(windowName)
    gui.textBox(2, 2, window.size.x - 2, window.size.y - 2, "Lorem ipsum #0xFF22AA dorom #0xFFFFFF test text with #0x22FFAA multiple lines")
end


local function testWindow()
    local window = manager.createWindow("Window "..i, {x=20, y=10}, {x=math.random(140), y=math.random(50)}, i, _, {{name="Test button", func=nil, args={}}}, true)
    manager.addComponent("Window "..i, testConstuctor, {"Window "..i, "Test text"})
    --manager.addComponent("Window "..i, graphics.windowBorder, {_, true, false})
    renderer.addWindow(window)
    i = i + 1
end


for i = 1, 10 do
    testWindow()
end

manager.enableWindowMovement()
renderer.update()