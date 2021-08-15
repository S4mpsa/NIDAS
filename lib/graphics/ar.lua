local screen = require("lib.utils.screen")
local colors = require("lib.graphics.colors")

local arGraphics = {}

local function RGB(hex)
    local r = ((hex >> 16) & 0xFF) / 255.0
    local g = ((hex >> 8) & 0xFF) / 255.0
    local b = ((hex) & 0xFF) / 255.0
    return r, g, b
end


--HUD Drawing functions:
--Verticex (v_) are a table with the X and Y values {x, y}. Colours are given as hex values. Alpha is 0.0 to 1.0.
--The first vertex is always the top left corner.
--Functions return an identifier to the object created.
function arGraphics.triangle(glasses, v1, v2, v3, color, alpha)
    alpha = alpha or 1.0
    local triangle = glasses.addTriangle()
    triangle.setColor(RGB(color))
    triangle.setAlpha(alpha)
    triangle.setVertex(1, v1[1], v1[2])
    triangle.setVertex(2, v2[1], v2[2])
    triangle.setVertex(3, v3[1], v3[2])
    return triangle
end

function arGraphics.quad(glasses, v1, v2, v3, v4, color, alpha)
    alpha = alpha or 1.0
    local quad = glasses.addQuad()
    quad.setColor(RGB(color))
    quad.setAlpha(alpha)
    quad.setVertex(1, v1[1], v1[2])
    quad.setVertex(2, v2[1], v2[2])
    quad.setVertex(3, v3[1], v3[2])
    quad.setVertex(4, v4[1], v4[2])
    return quad
end

function arGraphics.rectangle(glasses, v1, width, heigth, color, alpha)
    alpha = alpha or 1.0
    local rect = glasses.addQuad()
    rect.setColor(RGB(color))
    rect.setAlpha(alpha)
    rect.setVertex(1, v1[1], v1[2])
    rect.setVertex(2, v1[1], v1[2] + heigth)
    rect.setVertex(3, v1[1] + width, v1[2] + heigth)
    rect.setVertex(4, v1[1] + width, v1[2])
    return rect
end

function arGraphics.text(glasses, string, v1, color, scale)
    scale = scale or 1
    color = color or 0xFFFFFF
    local text = glasses.addTextLabel()
    text.setText(string)
    text.setPosition(v1[1], v1[2])
    text.setColor(RGB(color))
    if scale == 1 then
        text.setScale(scale)
    else
        local oldX, oldY = text.getPosition()
        oldX = oldX * text.getScale()
        oldY = oldY * text.getScale()
        text.setScale(scale)
        text.setPosition(oldX/(scale * 2), oldY/(scale * 2))
    end
    return text
end 

function arGraphics.remove(glasses, objects)
    for i = 1, #objects do
        glasses.removeObject(objects[i].getID())
    end
end

function arGraphics.clear(glasses)
    glasses.removeAll()
end

function arGraphics.testGrid(glasses, resolution, scale)
    scale = scale or 3
    local glassResolution = screen.size(resolution, scale)
    arGraphics.rectangle(glasses, {glassResolution[1]/2, 0}, 1, glassResolution[2], colors.electricBlue)
    arGraphics.rectangle(glasses, {0, glassResolution[2]/2}, glassResolution[1], 1, colors.electricBlue)
end

function arGraphics.borders(glasses, resolution, scale)
    scale = scale or 3
    local glassResolution = screen.size(resolution, scale)
    arGraphics.rectangle(glasses, {0, 0}, glassResolution[1], 1, colors.electricBlue)
    arGraphics.rectangle(glasses, {0, 0}, 1, glassResolution[2], colors.electricBlue)
    arGraphics.rectangle(glasses, {0, glassResolution[2]-1}, glassResolution[1], 1, colors.electricBlue)
    arGraphics.rectangle(glasses, {glassResolution[1]-1, 0}, 1, glassResolution[2], colors.electricBlue)
end

function arGraphics.testHud(glasses)
    local component = require("component")
    local glasses = component.proxy(component.get(glasses))
    arGraphics.text(glasses, "HUD Test", {1, 1})
    local c = glasses.addFloatingText()
    c.setText("Machine Disabled")
    c.set3DPos(0.5, 1.5, 0.5)
    c.setScale(0.1)
    c.setAlpha(1)
    c.setColor(RGB(0xFF0000))
end

return arGraphics

