local component = require("component")

local gpu = component.gpu

local gui = {}

local activeWindow = nil

function gui.setActiveWindow(window)
    gpu.setActiveBuffer(window.buffer)
    activeWindow = window
end

---Statix text on a single line, with uniform color.
---
---`name: string` The name used to refer to this window. Required
---
---`size: {x=number, y=number}` Size of the window. Required.
---
---`pos: {x=number, y=number}` Location of the window. Default {x=0, y=0}
---
---`depth: number` Rendering layer of the window. Zero is always on top. Default 0.
---@param name string
---@param size xypair
---@param pos xypair
---@param depth number
function gui.staticText(x, y, string, color)
    color = color or 0xFFFFFF
    gpu.setForeground(color)
    gpu.set(x, y, string)
end

function gui.textBox(x, y, w, h, text)
    local tokens = stringUtils.split(text)
    local lineWidth = 0
    local line = 0
    for _, token in ipairs(tokens) do
        if string.sub(token, 1, 1) == "#" then
            local value = tonumber(string.sub(token, 2))
            if type(value) == "number" then
                gpu.setForeground(tonumber(string.sub(token, 2)))
            end
        else
            if line > h then return end
            if lineWidth + #token <= w then
                gpu.set(x + lineWidth, y+line, token)
                lineWidth = lineWidth + #token + 1
            else
                lineWidth = 0
                line = line + 1
                if lineWidth + #token <= w then
                    gpu.set(x + lineWidth, y+line, token)
                    lineWidth = lineWidth + #token + 1
                end
            end
        end
    end
end

return gui