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
local focused = false

function renderer.setFocus()
    focused = true
end

function renderer.leaveFocus()
    focused = false
end

--An object is created by calling renderer.createObject(x, y, width, height)
--This returns a page number which can be used to manipulate the object.
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

--Objects can be removed by calling renderer.removeObject(pages)
--They can be removed one-by-one, or as a bulk operation by passing a table of pages.
function renderer.removeObject(pages)
    if type(pages) == "table" then
        for i = 1, #pages do
            local j = 1
            while objects[j] ~= nil do
                if objects[j].page == pages[i] then
                    objects[j].gpu.freeBuffer(pages[i])
                    table.remove(objects, j)
                else
                    j = j + 1
                end
            end
        end
    elseif type(pages) == "integer" then
        for j = 1, #objects do
            if objects[j].page == pages then
                objects[j].gpu.freeBuffer(pages)
                table.remove(objects, j)
            end
        end
    end
end

--All objects (or parts of the objects) can be made to react to clicks. This is done by calling renderer.setClickable(page, function, arguments, v1, v2)
--page is the identifier given by createObject() to select which object you want to make clickable.
--Function is the function that is called with function(arguments) on click of the area.
--Arguments is a table {arg1, arg2, arg3, ...} which is passed to the function given.
--v1 and v2 are the top left and bottom right bounds of the clickable area, given as a pair {x1, y1} and {x2, y2}
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

--All changes are buffered in video memory and only rendered on calling renderer.update()
--This will render all objects at their x and y locations. Rendering is first-in-first-rendered, so to overlay things on top of other objects, you need to create the underlying object first.
function renderer.update()
    local gpu = graphics.context().gpu
    for i = 1, #objects do
        local o = objects[i]
        gpu.bitblt(0, o.x, o.y, o.width, o.heigth, o.page, 1, 1)
    end
end

local function checkClick(_, _, X, Y)
    if not focused then
        for i = 1, #objects do
            local o = objects[i]
            if o ~= nil then
                if o.clickable then
                    local v1 = o.clickArea[1]
                    local v2 = o.clickArea[2]
                    if X >= v1[1] and X < v2[1] and Y >= v1[2] and Y < v2[2] then
                        if o.args ~= nil then
                            o.clickFunction(table.unpack(o.args))
                            return
                        else
                            o.clickFunction()
                            return
                        end
                    end
                end
            end
        end
    end
end

function event.onError(message)
    print(message)
end

event.listen("touch", checkClick)

return renderer

