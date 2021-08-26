local graphics = require("lib.graphics.graphics")
local component = require("component")
local event = require("event")
local renderer = {}

local objects = {}
local windows = {}
local primaryScreen = component.screen.address
local multicasting = true

function renderer.setMulticasting(value)
    multicasting = value
end

function renderer.setPrimaryScreen(address)
    primaryScreen = address
end

function renderer.clear()
    graphics.context().gpu.setActiveBuffer(0)
    graphics.context().gpu.freeAllBuffers()
    objects = {}
end

local activeWindow = "main"

function renderer.clearWindow(name)
    local gpu = graphics.context().gpu
    for i = 1, #windows[name] do
        gpu.freeBuffer(windows[name][i].page)
    end
    windows[name] = {}
end

function renderer.switchWindow(name)
    windows[activeWindow] = objects
    objects = windows[name] or {}
    activeWindow = name
    graphics.clear()
    renderer.update()
end

local focused = false
--To disable click detection
function renderer.setFocus()
    focused = true
end
--To re-enable click detection
function renderer.leaveFocus()
    focused = false
end

function renderer.focused()
    return focused
end
function event.onError(message)
    local _, y = graphics.context().gpu.getResolution()
    print(message)
    graphics.text(40, y*2-3, message)
end

function renderer.multicast()
    if multicasting then
        local screens = 0
        for address, t in component.list() do
            if t == "screen" then screens = screens + 1 end
        end
        if screens > 1 then
            local gpu = graphics.context().gpu
            local width, height = graphics.context().width, graphics.context().height
            local screenBuffer = gpu.allocateBuffer(width, height)
            gpu.bitblt(screenBuffer, 1, 1, width, height, 0, 1, 1)
            for address, t in component.list() do
                if t == "screen" and address ~= primaryScreen then
                    gpu.bind(address, false)
                    gpu.setResolution(width, height)
                    gpu.bitblt(0, 1, 1, width, width, screenBuffer, 1, 1)
                end
            end
            gpu.bind(primaryScreen, false)
            gpu.freeBuffer(screenBuffer)
        end
    end
end

--An object is created by calling renderer.createObject(x, y, width, height)
--This returns a page number which can be used to manipulate the object.
function renderer.createObject(x, y, width, height, alwaysVisible)
    if width < 0 or height < 0 then error("Dimensions must be positive") end
    alwaysVisible = alwaysVisible or false
    local gpu = graphics.context().gpu
    local page = gpu.allocateBuffer(width, height)
    table.insert(objects, {
        gpu = gpu,
        page = page,
        x = x,
        y = y,
        width = width,
        height = height,
        state = 0,
        clickable = false,
        clickArea = {{0, 0}, {0, 0}},
        clickFunction = nil,
        args = nil,
        boundScreens = 0,
        alwaysVisible = alwaysVisible
    })
    return page
end

function renderer.getScreenCoordinates(bufferX, bufferY)
    local currentObject = nil
    local currentPage = graphics.context().gpu.getActiveBuffer()
    for object in objects do
        if object.page == currentPage then
            currentObject = object
        end
    end
    if currentObject ~= nil then
        return bufferX + currentObject.x, bufferY + currentObject.y
    end
end

--Objects can be removed by calling renderer.removeObject(pages)
--They can be removed one-by-one, or as a bulk operation by passing a table of pages.
function renderer.removeObject(pages)
    if type(pages) == "table" then
        for i = 1, #pages do
            local j = 1
            while objects[j] ~= nil do
                if objects[j].page == pages[i] then
                    local removed = objects[j].gpu.freeBuffer(pages[i])
                    table.remove(objects, j)
                else
                    j = j + 1
                end
            end
        end
    elseif type(pages) == "number" then
        for j = 1, #objects do
            if objects[j].page == pages then
                local removed = objects[j].gpu.freeBuffer(pages)
                table.remove(objects, j)
                return
            end
        end
    end
end

--All objects (or parts of the objects) can be made to react to clicks. This is done by calling renderer.setClickable(page, function, arguments, v1, v2)
--page is the identifier given by createObject() to select which object you want to make clickable.
--Function is the function that is called with function(arguments) on click of the area.
--Arguments is a table {arg1, arg2, arg3, ...} which is passed to the function given.
--v1 and v2 are the top left and bottom right bounds of the clickable area, given as a pair {x1, y1} and {x2, y2}
function renderer.setClickable(object, onClick, args, v1, v2, lowPriority)
    for i = 1, #objects do
        if objects[i].page == object then
            objects[i].clickable = true
            objects[i].clickArea = {v1, v2}
            objects[i].clickFunction = onClick
            objects[i].args = args
            if lowPriority then objects[i].lowPriority = true end
            return true
        end
    end
    return false
end

--All changes are buffered in video memory and only rendered on calling renderer.update()
--This will render all objects at their x and y locations. Rendering is first-in-first-rendered, so to overlay things on top of other objects, you need to create the underlying object first.
--Passing a list of pages only updates those pages.
function renderer.update(pages)
    local gpu = graphics.context().gpu
    gpu.bind(primaryScreen, false)
    gpu.setResolution(graphics.context().width, graphics.context().height)
    local renderOnTop = {}
    for i = 1, #objects do
        local o = objects[i]
        if o.page == nil then error("Object page is nil") end
        if pages ~= nil then
            for p = 1, #pages do
                if pages[p] == o.page then
                    gpu.bitblt(0, o.x, o.y, o.width, o.height, o.page, 1, 1)
                end
            end
        else
            if o.alwaysVisible then
                table.insert(renderOnTop, o)
            else
                gpu.bitblt(0, o.x, o.y, o.width, o.height, o.page, 1, 1)
            end
        end
    end
    for i = 1, #renderOnTop do
        local o = renderOnTop[i]
        gpu.bitblt(0, o.x, o.y, o.width, o.height, o.page, 1, 1)
    end
    renderer.multicast()
    if DEBUG then
        local str = ""
        local bufferSum = 0
        for i = 1, #objects do
            local o = objects[i]
            if o.page ~= nil then
                bufferSum = bufferSum + gpu.getBufferSize(objects[i].page)
                str = str .. math.floor(objects[i].page) .."("..gpu.getBufferSize(objects[i].page)..") "
            else
                str = str .. "nil "
            end
        end
        local _, y = gpu.getResolution()
        --graphics.text(1, y*2-5, str)
        graphics.text(1, y*2-3, "Memory free: "..gpu.freeMemory().."      ")
        graphics.text(1, y*2-1, "Memory used by buffers: "..bufferSum.."    ")
        renderer.multicast()
    end
end

local clickX, clickY
function renderer.getX() return clickX end
function renderer.getY() return clickY end

local function checkClick(_, _, X, Y)
    if not focused then
        if DEBUG then
            local _, y = graphics.context().gpu.getResolution()
            graphics.text(35, y*2-1, "Registered click at: "..X.." "..Y.."      ")
        end
        clickX = X
        clickY = Y
        local function activate(o)
            if o.args ~= nil then
                if type(o.clickFunction) == "function" then
                    o.clickFunction(table.unpack(o.args))
                elseif type(o.clickFunction) == "table" then
                    for f = 1, #o.clickFunction do
                        o.clickFunction[f](table.unpack(o.args))
                    end
                end
                return
            else
                if type(o.clickFunction) == "function" then
                    o.clickFunction()
                elseif type(o.clickFunction) == "table" then
                    for f = 1, #o.clickFunction do
                        o.clickFunction[f]()
                    end
                end
                return
            end
        end
        local lowPriorityObject = nil
        local clicked = false
        for i = 1, #objects do
            local o = objects[i]
            if o ~= nil then
                if o.clickable then
                    local v1 = o.clickArea[1]
                    local v2 = o.clickArea[2]
                    if X >= v1[1] and X < v2[1] and Y >= v1[2] and Y < v2[2] then
                        if o.lowPriority then
                            lowPriorityObject = o
                        else
                            activate(o)
                            clicked = true
                        end
                    end
                end
            end
        end
        if not clicked then activate(lowPriorityObject) end
    end
end

event.listen("touch", checkClick)

return renderer

