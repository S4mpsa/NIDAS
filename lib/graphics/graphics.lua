--This graphics library is created to be compatible with shaders. As a result, all background colour changing operations are unused.
--This creates limitations, but ensures the visuals look the same for everyone with no glitches.
--It also forces a certain aesthetic to everything with black backgrounds on all text.
--It supports doubled verticla resolution for square pixels.
local graphics = {}
local context = {
    gpu = nil,
    width = 0,
    height = 0
}

function graphics.setContext(rendererObject)
    if rendererObject ~= nil then
        context.gpu = rendererObject.gpu
        context.width = rendererObject.width
        context.height = rendererObject.height
    else
        local gpu = require("component").gpu
        local width, height = gpu.getResolution()
        context.gpu = gpu
        context.width = width
        context.height = height
    end
end

function graphics.context()
    return context
end

local function pixel(x, y, color)
    local gpu = context.gpu
    local screenY = math.ceil(y/2)
    gpu.setForeground(color)
    if y % 2 == 1 then --Upper half of pixel
        gpu.set(x, screenY, "▀");
    else --Lower half of pixel
        gpu.set(x, screenY, "▄");
    end
end

function graphics.rectangle(x, y, width, height, color)
    local gpu = context.gpu
    local hLeft = height
        if x > 0 and y > 0 then
        if y % 2 == 0 then
            for i = x, x+width-1 do
                pixel(i, y, color)
            end
            hLeft = hLeft - 1
        end
        gpu.setForeground(color)
        if hLeft % 2 == 1 then
            gpu.fill(x, math.ceil(y/2)+(height-hLeft), width, (hLeft-1)/2, "█")
            for j = x, x+width-1 do
                pixel(j, y+height-1, color)
            end
        else
            gpu.fill(x, math.ceil(y/2)+(height-hLeft), width, hLeft/2, "█")
        end
    end
end

function graphics.outline(x, y, lines, color)
    color = color or 0xFFFFFF
    for i = 0, #lines-1 do
        graphics.text(x, y+i*2, lines[i+1], color)
    end
end

function graphics.clear()
    context.gpu.fill(1, 1, context.width, context.height, " ")
end

function graphics.text(x, y, text, color, useStandardY)
    color = color or 0xFFFFFF
    if not useStandardY and y % 2 == 0 then
        error("Y must be odd.")
    else
        local gpu = context.gpu
        local screenY
        if useStandardY then
            screenY = y
        else
            screenY = math.ceil(y/2)
        end
        gpu.setForeground(color)
        gpu.set(x, screenY, text)
    end
end
return graphics