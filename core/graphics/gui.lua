local gpu = require("component").gpu

local stringUtils = require('core.lib.stringUtils')

local gui = {}

function gui.setActiveWindow(window)
    gpu.setActiveBuffer(window.buffer)
end

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
                gpu.set(x + lineWidth, y + line, token)
                lineWidth = lineWidth + #token + 1
            else
                lineWidth = 0
                line = line + 1
                if lineWidth + #token <= w then
                    gpu.set(x + lineWidth, y + line, token)
                    lineWidth = lineWidth + #token + 1
                end
            end
        end
    end
end

return gui
