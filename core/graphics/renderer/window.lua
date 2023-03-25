--Defines a window class that is the frame of all graphical elements.

local component = require("component")
local gpu = component.gpu

local windowClass = {}

local template = {
    ID = nil,
    size = {x=160, y=50},   --Size of the window
    position = {x=0, y=0},  --Position on the 
    depth = 0,              --Depth on screen, lowest are on top
    buffer = 0,             --GPU Page of window
    elements = {},          --Elements of the window
}


local function checkClick(window, element, x, y)
    if (y >= window.position.y + element.position.y - 1 and y < window.position.y + element.position.y + element.size.y - 1)
    and (x >= window.position.x + element.position.x - 1 and x < window.position.x + element.position.x + element.size.x - 1) then
        return true
    else
        return false
    end
end

local function onClick(window, eventName, address, x, y, button, name)
    --Handle clicks for elements
    for i = #window.elements, 1, -1 do
        if checkClick(window, window.elements[i], x, y) then
            if button == 0 then
                if eventName == "touch" then
                    if window.elements[i].onClick(window, window.elements[i], eventName, address, x, y, button, name) then
                        return
                    end
                elseif eventName == "drag" then
                    if window.elements[i].onDrag(window, window.elements[i], eventName, address, x, y, button, name) then
                        return
                    end 
                end
            elseif button == 1 then
                if eventName == "touch" then
                    if window.elements[i].onClickRight(window, window.elements[i], eventName, address, x, y, button, name) then
                        return
                    end
                elseif eventName == "drag" then
                    if window.elements[i].onDragRight(window, window.elements[i], eventName, address, x, y, button, name) then
                        return
                    end
                end
            end
        end
    end
    --No element was clicked, handle window clicks
    if button == 0 then --Left click
        if eventName == "drag" then
            if window.movingEnabled and y >= window.position.y - 1 and y <= window.position.y + 1 then
                gpu.fill(window.position.x, window.position.y, window.size.x, window.size.y, " ")
                window.position = {x = x - window.xOffset, y = y}
                refresh()
            end
        elseif eventName == "touch" then
            if y == window.position.y then
                window.xOffset = x - window.position.x
            end
        end
    elseif button == 1 and eventName == "touch" then --Right click
        contextMenu(window, window.options, x, y)
    end
end

function windowClass.update(window)
    gpu.setActiveBuffer(window.buffer)
    for _, element in ipairs(window.elements) do
        element.draw(window, element)
    end
end

---@param size Coordinate2D
---@param position Coordinate2D
function windowClass.create(name, size, position)
    local buffer = gpu.allocateBuffer(math.max(size.x, 2), math.max(size.y, 2))
    if buffer ~= nil then
        local window = {
            name = name,
            size = size,
            position = position,
            depth = 0,
            buffer = buffer,
            elements = {},
            onClick = onClick,
            options = {},
            movingEnabled = false
        }
        -------------------------------------------
        local function remove()
            gpu.freeBuffer(window.buffer)
            gpu.setActiveBuffer(0)
            gpu.fill(window.position.x, window.position.y, window.size.x, window.size.y, " ")
            window = {}
            refresh()
        end
        window.remove = remove
        -------------------------------------------
        local function setActive()
            gpu.setActiveBuffer(window.buffer)
            return window
        end
        window.setActive = setActive
        -------------------------------------------
        ---@param options table
        local function setOptions(options)
            window.options = options
            return window
        end
        window.setOptions = setOptions
        -------------------------------------------
        local function enableMovement()
            window.movingEnabled = true
        end
        window.enableMovement = enableMovement
        -------------------------------------------
        ---@param element Element
        local function addElement(element)
            table.insert(window.elements, element)
            return window
        end
        window.addElement = addElement
        -------------------------------------------
        ---@param elements table
        local function addElements(elements)
            for _, element in ipairs(elements) do
                table.insert(window.elements, element)
            end
            return window
        end
        window.addElements = addElements
        -------------------------------------------
        local function update()
            gpu.setActiveBuffer(window.buffer)
            for _, element in ipairs(window.elements) do
                element.draw(window, element)
            end
        end
        window.update = update
        -------------------------------------------
        return window
    else
        error("Window creation failed.")
    end
end

return windowClass