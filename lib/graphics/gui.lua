local renderer = require("renderer")
local graphics = require("graphics")
local component = require("component")
local colors    = require("colors")
local event = require("event")
local gui = {}

local borderColor = colors.darkGray
local accentColor = colors.electricBlue

function gui.configurationMenu(objects)

end

function gui.selectionBox(x, y, choices)
    local context = graphics.context()
    local maxX = context.width
    local maxY = context.heigth
    local gpu = context.gpu
    local longestName = 0
    for i = 1, #choices do
        if #choices[i].displayName > longestName then longestName = #choices[i].displayName end
    end
    longestName = longestName + 2
    local heigth = #choices + 2
    if maxX <= (x+longestName+5) then x = maxX-(longestName+4) end
    if maxY <= (y+heigth) then y = maxY-(heigth-1) end
    local page = gpu.allocateBuffer(longestName+2, heigth)
    gpu.setActiveBuffer(page)
    graphics.rectangle(1, 1, 2+longestName, 1, borderColor)
    graphics.rectangle(1, 4+2*#choices, 2+longestName, 1, borderColor)
    graphics.rectangle(1, 1, 1, 4+2*#choices, borderColor)
    graphics.rectangle(2+longestName, 1, 1, 4+2*#choices, borderColor)
    graphics.rectangle(2, 3, longestName, 2*#choices, colors.black)
    for i = 1, #choices do
        graphics.text(3, 1+2*i, choices[i].displayName, accentColor)
    end
    gpu.setActiveBuffer(0)
    local background = gpu.allocateBuffer(longestName+2, heigth)
    gpu.bitblt(background, 1, 1, maxY, maxX, 0, y, x)
    gpu.bitblt(_, x, y, maxX, maxY, page)
    local _, _, touchX, touchY, button, _ = event.pull(_, "touch")
    gpu.bitblt(0, x, y, maxX, maxY, background)
    if touchX > x and touchX < x+longestName+1 and touchY > y and touchY < y+heigth then
        print(touchY - y)
        return choices[touchY-y].value
    else
        return nil
    end
end

local function compareColors(a,b)
    return a[2] < b[2]
  end
function gui.colorSelection(x, y, colorList)
    local context = graphics.context()
    local maxX = context.width
    local maxY = context.heigth
    local gpu = context.gpu
    local colorTable = {}
    local longestName = 0
    for name, value in pairs(colorList) do
        if #name > longestName then longestName = #name end
        table.insert(colorTable, {name, value})
    end
    table.sort(colorTable, compareColors)
    local heigth = #colorTable + 2
    if maxX <= (x+longestName+5) then x = maxX-(longestName+4) end
    if maxY <= (y+heigth) then y = maxY-(heigth-1) end
    local page = gpu.allocateBuffer(longestName+5, heigth)
    gpu.setActiveBuffer(page)
    graphics.rectangle(1, 1, 5+longestName, 4+2*#colorTable, borderColor)
    graphics.rectangle(5, 3, longestName, 2*#colorTable, colors.black)
    for i = 1, #colorTable do
        graphics.text(5, 1+2*i, colorTable[i][1], colorTable[i][2])
        graphics.rectangle(2, 1+2*i, 2, 2, colorTable[i][2])
    end
    gpu.setActiveBuffer(0)
    local background = gpu.allocateBuffer(longestName+5, heigth)
    gpu.bitblt(background, 1, 1, maxY, maxX, 0, y, x)
    gpu.bitblt(_, x, y, maxX, maxY, page)
    local _, _, touchX, touchY, button, _ = event.pull(_, "touch")
    gpu.bitblt(0, x, y, maxX, maxY, background)
    if touchX > x and touchX < x+longestName+4 and touchY > y and touchY < y+heigth then
        return colorTable[touchY-y][2]
    else
        return nil
    end
end

return gui