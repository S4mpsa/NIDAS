--Handles window assignment and window switching.

local component = require("component"); local event = require("event")
local graphics = require("core.graphics.drawing.graphics")
local renderer = require("core.graphics.renderer")

local gpu = component.gpu

local manager = {}

local startWindow = {
    name = "Screen",
    size = {x=160, y=50},
    pos = {x=0, y=0},
    depth = 0,
    buffer = 0,
    components = {},
    context = nil
}

local windows = {startWindow}

--Internal function to change the active window.
local function changeWindow(newWindow)
    local window = newWindow
    graphics.changeWindow(window)
end

function manager.addComponent(name, func, args)
    for i, window in ipairs(windows) do
        if window.name == name then
            table.insert(windows[i].components, {func=func, args=args})
            gpu.setActiveBuffer(window.buffer)
            func(table.unpack(args))
            return
        end
    end
end

function manager.getWindow(name)
    for _, window in ipairs(windows) do
        if window.name == name then
            return window
        end
    end
    error("No window named "..name.." exists")
end

function manager.changeWindow(name)
    for _, window in ipairs(windows) do
        if window.name == name then
            changeWindow(window)
            return
        end
    end
    error("No window named "..name.." exists")
end

---Creates a new window and changes it to be active.
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
function manager.createWindow(name, size, pos, depth, components, context, closeable)
    local page = gpu.allocateBuffer(math.max(size.x, 2), math.max(size.y, 2))
    pos = pos or {x=0, y=0}
    components = components or {}
    context = context or {}
    depth = depth or 0
    closeable = closeable or false
    table.insert(windows, {
        name = name,
        size = size,
        pos = pos,
        depth = depth,
        buffer = page,
        components = components,
        context = context
    })
    if closeable then
        table.insert(windows[#windows].context, {name="Close window", func=renderer.closeWindow, args={name}})
    end
    changeWindow(windows[#windows])
    if #components > 0 then
        gpu.setActiveBuffer(page)
        for cname, c in pairs(components) do
            c.func(table.unpack(c.args))
        end
    end
    return windows[#windows]
end

function manager.removeWindow(name)
    for i, window in ipairs(windows) do
        if window.name == name then
            gpu.freeBuffer(window.buffer)
            table.remove(windows, i)
            return
        end
    end
end

local movingWindow = nil
local resizingWindow = nil
local resizingDirection = nil
local function attachWindow(eventName, address, x, y, button, name)
    local activeWindows = renderer.getActiveWindows()
    for i, _ in ipairs(activeWindows) do
        window = activeWindows[#activeWindows-i + 1]
        --if (x == window.pos.x + window.size.x - 2 and y == window.pos.y) then renderer.closeWindow(window.name)
        if (y > window.pos.y and y < window.pos.y + window.size.y - 1) and (x > window.pos.x and x < window.pos.x + window.size.x - 1) then
            movingWindow = {name = window.name, anchor = {x = x - window.pos.x, y = y - window.pos.y} }
            resizingWindow = nil
            resizingDirection = nil
            return
        elseif (y >= window.pos.y and y < window.pos.y + window.size.y) and (x >= window.pos.x and x < window.pos.x + window.size.x) then --Check for resizing
            movingWindow = nil
            resizingWindow = {name = window.name, anchor = {x = x, y = y} }
            if     (y == window.pos.y) and (x > window.pos.x and x < window.pos.x + window.size.x - 1) then resizingDirection = 1 -- Up
            elseif (y == window.pos.y) and (x == window.pos.x + window.size.x - 1) then resizingDirection = 2 -- Up Right
            elseif (y > window.pos.y and y < window.pos.y + window.size.y - 1) and (x == window.pos.x + window.size.x - 1) then resizingDirection = 3 -- Right
            elseif (y == window.pos.y + window.size.y - 1) and (x == window.pos.x + window.size.x - 1) then resizingDirection = 4 -- Down Right
            elseif (y == window.pos.y + window.size.y - 1) and (x > window.pos.x and x < window.pos.x + window.size.x - 1) then resizingDirection = 5 -- Down
            elseif (y == window.pos.y + window.size.y - 1) and (x == window.pos.x) then resizingDirection = 6 -- Down Left
            elseif (y > window.pos.y and y < window.pos.y + window.size.y - 1) and (x == window.pos.x) then resizingDirection = 7 -- Left
            elseif (y == window.pos.y) and (x == window.pos.x) then resizingDirection = 8 end -- Up Left 
            return
        end
    end
    movingWindow = nil
    resizingWindow = nil
    resizingDirection = nil
end

local contextAnchor = {}
local background = nil
local clickHandler = nil
local function contextHandler(eventName, address, x, y, button, name)
    if (y > contextAnchor.pos.y and y < contextAnchor.pos.y + contextAnchor.size.y - 1) and (x > contextAnchor.pos.x and x < contextAnchor.pos.x + contextAnchor.size.x - 1) then
        local selection = y - contextAnchor.pos.y
        print(contextAnchor.contexts[selection].args[1])
        contextAnchor.contexts[selection].func(table.unpack(contextAnchor.contexts[selection].args))
        renderer.removeWindow("ContextMenu")
        manager.removeWindow("ContextMenu")
    end
    renderer.removeWindow("ContextMenu")
    manager.removeWindow("ContextMenu")
    gpu.bitblt(0, contextAnchor.pos.x, contextAnchor.pos.y, contextAnchor.size.x, contextAnchor.size.y, background.buffer, 1, 1)
    manager.removeWindow("ContextBackground")
    attachWindow(eventName, address, x, y, button, name)
    renderer.update()
    manager.enableWindowMovement()
    event.ignore("touch", contextHandler)
end

local function contextMenu(eventName, address, x, y, button, name)
    local activeWindows = renderer.getActiveWindows()
    for i, _ in ipairs(activeWindows) do
        local window = activeWindows[#activeWindows-i + 1]
        local longestEntry = 0
        for _, v in ipairs(window.context) do
            if longestEntry < #v.name then
                longestEntry = #v.name
            end
        end
        if (y > window.pos.y and y < window.pos.y + window.size.y - 1) and (x > window.pos.x and x < window.pos.x + window.size.x - 1) then
            local contextmenu = manager.createWindow("ContextMenu", {x=longestEntry+2, y=#window.context+2}, {x=x, y=y}, 0)
            contextAnchor = {
                pos = {x=x, y=y},
                size = {x=longestEntry+2, y=#window.context+2},
                contexts = window.context
            }
            gpu.setActiveBuffer(contextmenu.buffer)
            graphics.windowBorder(0xFF00FF, false, false)
            gpu.setForeground(0xFF22BB)
            i = 2
            for _, context in ipairs(window.context) do
                gpu.set(2, i, context.name)
                i = i + 1
            end
            renderer.addWindow(contextmenu)
            background = manager.createWindow("ContextBackground", {x=longestEntry+2, y=#window.context+2}, {x=x, y=y}, 0)
            gpu.bitblt(background.buffer, 1, 1, contextAnchor.size.x, contextAnchor.size.y, 0, contextAnchor.pos.x, contextAnchor.pos.y)
            renderer.update()
            manager.disableWindowMovement()
            event.listen("touch", contextHandler)
            return
        end
    end
end

local function moveWindow(eventName, address, x, y, button, name)
    if movingWindow then
        renderer.moveWindow(movingWindow.name, x-movingWindow.anchor.x, y-movingWindow.anchor.y)
    elseif resizingWindow then
        renderer.resizeWindow(resizingWindow.name, resizingDirection, x, y)
    end
end

local function handleClick(eventName, address, x, y, button, name)
    if button == 0 then
        attachWindow(eventName, address, x, y, button, name)
    elseif button == 1 then
        contextMenu(eventName, address, x, y, button, name)     
    end
end
clickHandler = handleClick

function manager.enableWindowMovement()
    event.listen("touch", handleClick)
    event.listen("drag", moveWindow)
end

function manager.disableWindowMovement()
    event.ignore("touch", handleClick)
    event.ignore("drag", moveWindow)
end

return manager