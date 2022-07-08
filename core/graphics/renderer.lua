local component = require("component")
local num = require("core.lib.numUtils")
local gpu = component.gpu

local activeWindows = {}

local renderer = {}
---Returns a table of currently active windows.
function renderer.getActiveWindows()
    return activeWindows
end

---Sorts the active window list depth-wise so lowest depth is always rendered on top.
local function sortWindows()
    local function condition(window1, window2)
        return window1.depth > window2.depth
    end
    table.sort(activeWindows, condition)
end

---Adds a window to be rendered.
---@param window window
function renderer.addWindow(window)
    table.insert(activeWindows, window)
    sortWindows()
end

-- ---Checks if two windows have overlapping bounding boxes.
-- ---@param window1 window
-- ---@param window2 window
-- local function isWithin(window1, window2)
--     local x1, y1, w1, h1 = window1.pos.x, window1.pos.y, window1.size.x, window1.size.y
--     local x2, y2, w2, h2 = window2.pos.x, window2.pos.y, window2.size.x, window2.size.y
--     if (x1 <= x2+w2 and x1+w1 >= x2 and y1 <= y2+h2 and y1+h1 >= y2) then return true else return false
--     end
-- end

-- ---Checks if query window overlaps any of the windows in table.
-- ---@param queryWindow window
-- ---@param table table
-- local function overlaps(queryWindow, table)
--     for _, window in ipairs(table) do
--         if isWithin(queryWindow, window) then
--             return true
--         end
--     end
--     return false
-- end

-- ---Updates a window and any windows that would be overlapped by updated windows.
-- local function limitedUpdate(anchor)
--     gpu.setActiveBuffer(0)
--     local updatedWindows = {anchor}
--     for _, window in ipairs(activeWindows) do
--         local pos = window.pos
--         local size = window.size
--         if overlaps(window, updatedWindows) then
--             gpu.bitblt(0, pos.x, pos.y, size.x, size.y, window.buffer, 1, 1)
--             table.insert(updatedWindows, window)
--         end
--     end
-- end

---Moves a window with `name` to `x`, `y`.
---@param name string
---@param x number
---@param y number
function renderer.moveWindow(name, x, y)
    for i, window in ipairs(activeWindows) do
        local pos = window.pos
        local size = window.size
        if window.name == name then
            gpu.setActiveBuffer(0)
            gpu.fill(pos.x, pos.y, size.x, size.y, " ")
            activeWindows[i].pos = {x=x, y=y}
            renderer.update()
            return
        end
    end
end

local function createNewWindow(direction, x, y, name, size, pos, window, manager)
    local function createWindow(newSize, newPos)
        return manager.createWindow(name, newSize, newPos, window.depth, window.components, window.context)
    end

    if direction == 1 then --Up
        return createWindow(
            {
                x = size.x,
                y = size.y + (pos.y - y)
            },
            { x = pos.x, y = y }
        )
    elseif direction == 2 then --Up Right
        return createWindow(
            {
                x = num.clamp(size.x + (x - pos.x - size.x + 1), 2, 160),
                y = num.clamp(size.y + (pos.y - y), 2, 60)
            },
            { x = pos.x, y = y }
        )
    elseif direction == 3 then --Right
        return createWindow(
            {
                x = size.x + (x - pos.x - size.x + 1),
                y = size.y
            },
            pos
        )
    elseif direction == 4 then --Down Right
        return createWindow(
            {
                x = size.x + (x - pos.x - size.x + 1),
                y = size.y + (y - pos.y - size.y + 1)
            },
            pos
        )
    elseif direction == 5 then --Down
        return createWindow(
            {
                x=size.x,
                y=size.y + (y - pos.y - size.y + 1)
            },
            pos
        )
    elseif direction == 6 then --Down Left
        return createWindow(
            {
                x = size.x + (pos.x - x),
                y = size.y + (y - pos.y - size.y + 1)
            },
            { x = x, y = pos.y}
        )
    elseif direction == 7 then --Left
        return createWindow(
            {
                x = size.x + (pos.x - x),
                y = size.y
            },
            { x = x, y = pos.y}
        )
    elseif direction == 8 then -- Up Left
        return createWindow(
            {
                x = size.x + (pos.x - x),
                y = size.y + (pos.y - y)
            },
            { x = x, y = y }
        )
    end
end

---Resizes a window
---
---Goes clockwise, starting from 1 = UP to 8 = TOP LEFT
---
---Still needs component integration
---@param name string
---@param direction number
---@param x number
---@param y number
function renderer.resizeWindow(name, direction, x, y, manager)
    for _, window in ipairs(activeWindows) do
        if window.name == name then
            local pos = window.pos
            local size = window.size

            renderer.removeWindow(name)
            manager.removeWindow(name)

            local newWindow = createNewWindow(direction, x, y, name, size, pos, window)
            renderer.addWindow(newWindow)
            sortWindows()

            gpu.setActiveBuffer(0)
            gpu.fill(pos.x, pos.y, size.x, size.y, " ")
            renderer.update()
            return
        end
    end
end

---Close a window and refresh all windows.
---@param name string
function renderer.closeWindow(name, manager)
    for i, window in ipairs(activeWindows) do
        if window.name == name then
            local pos = window.pos
            local size = window.size

            gpu.freeBuffer(window.buffer)
            table.remove(activeWindows, i)
            gpu.setActiveBuffer(0)
            gpu.fill(pos.x, pos.y, size.x, size.y, " ")
            renderer.update()
            manager.removeWindow(name)
            break
        end
    end
end

---Removes a window from being rendered.
---@param name string
function renderer.removeWindow(name)
    for i, window in ipairs(activeWindows) do
        if window.name == name then
            gpu.freeBuffer(window.buffer)
            table.remove(activeWindows, i)
            break
        end
    end
end


---Refreshes all active windows.
function renderer.update()
    gpu.setActiveBuffer(0)
    for _, window in ipairs(activeWindows) do
        local pos = window.pos
        local size = window.size

        gpu.bitblt(0, pos.x, pos.y, size.x, size.y, window.buffer, 1, 1)
    end
end

---Refreshes a specfic window.
---@param name string
function renderer.updateWindow(name)
    gpu.setActiveBuffer(0)
    for _, window in ipairs(activeWindows) do
        if window.name == name then
            local pos = window.pos
            local size = window.size

            gpu.bitblt(0, pos.x, pos.y, size.x, size.y, window.buffer, 1, 1)
            break
        end
    end
end

return renderer