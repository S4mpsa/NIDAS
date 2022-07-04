local component = require("component")

local gpu = component.gpu

local gui = {}

local activeWindow = nil

function gui.setActiveWindow(window)
    gpu.setActiveBuffer(window.buffer)
    activeWindow = window
end

function gui.staticText(x, y, string, color)
    color = color or 0xFFFFFF
    gpu.setForeground(color)
    gpu.set(x, y, string)
end

return gui