--This file contains GPU-level drawing commands for modifying the video buffer directly.
local gpu = require("component").gpu

local stringUtils = require("core.lib.stringUtils")

local graphics = {}
---@type window
local window

--Changes the window items are drawn to
function graphics.changeWindow(newWindow)
    window = newWindow
end

function graphics.test()
    gpu.setActiveBuffer(window.buffer)
    gpu.setForeground(math.random(2^24))
    gpu.fill(1, 1, window.size.x, window.size.y, "█")
end

function graphics.rectangle(x, y, width, heigth, color)
    gpu.setActiveBuffer(window.buffer)
    gpu.setForeground(color)
    gpu.fill(x, y, width, heigth, "█")
end

local borderColor = 0x555555 --Temporary
local primaryColor = 0xADD8E6
local accentColor = 0xDD00DD
function graphics.windowBorder(color, displayName)
    color = color or borderColor
    displayName = displayName or false
    gpu.setActiveBuffer(window.buffer)
    gpu.setForeground(color)
    local top = "╭"
    local edges = "│"
    local bottom = "╰"
    for _ = 1, window.size.x - 2 do
        top = top.."─"
        bottom = bottom.."─"
    end
    for _ = 1, window.size.y - 3 do
        edges = edges.."│"
    end
    top = top.."╮"
    bottom = bottom.."╯"
    gpu.set(1, 1, top)
    gpu.set(1, 2, edges, true)
    gpu.set(window.size.x, 2, edges, true)
    gpu.set(1, window.size.y, bottom)
    if displayName then
        gpu.setForeground(primaryColor)
        local words = stringUtils.split(window.name)
        local offset = 3
        for _, word in ipairs(words) do
            gpu.set(offset, 1, word)
            offset = offset + #word + 1
        end
    end
    gpu.setForeground(accentColor)
    --gpu.set(window.size.x-1, 1, "x")
end

return graphics
