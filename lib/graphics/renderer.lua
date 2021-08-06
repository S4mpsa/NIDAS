--local renderer = require("renderer")
local graphics = require("lib.graphics.graphics")
local component = require("component")
local colors    = require("lib.graphics.colors")
local event = require("event")
local uc = require("unicode")
local parser = require("lib.utils.parser")
local renderer = {}

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


local objects = {}

function renderer.createObject(x, y, width, heigth)
    local gpu = graphics.context().gpu
    local object = gpu.allocateBuffer(width, heigth)
    table.insert(objects, {
        gpu = gpu,
        page = object,
        x = x,
        y = y,
        width = width,
        heigth = heigth,
        state = 0,
        clickable = false,
        clickArea = {{0, 0}, {0, 0}},
        clickFunction = nil,
        args = nil,
        boundScreens = 0
    })
    return object
end

function renderer.setClickable(object, onClick, args, v1, v2)
    for i = 1, #objects do
        if objects[i].page == object then
            objects[i].clickable = true
            objects[i].clickArea = {v1, v2}
            objects[i].clickFunction = onClick
            objects[i].args = args
            return true
        end
    end
    return false
end
function renderer.update()
    local gpu = graphics.context().gpu
    for i = 1, #objects do
        local o = objects[i]
        gpu.bitblt(0, o.x, o.y, o.width, o.heigth, o.page, 1, 1)
    end
end

local function checkClick(_, _, X, Y)
    for i = 1, #objects do
        local o = objects[i]
        if o.clickable then
            local v1 = o.clickArea[1]
            local v2 = o.clickArea[2]
            if X >= v1[1] and X <= v2[1] and Y >= v1[2] and Y <= v2[2] then
                o.clickFunction(o.args[1], o.args[2], o.args[3], o.args[4], o.args[5], o.args[6], o.args[7])
            end
        end
    end
end

event.listen("touch", checkClick)

return renderer

