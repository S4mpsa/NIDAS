--Defines a window class that is the frame of all graphical elements.

local component = require("component")
local gpu = component.gpu

local hudWindowClass = {}

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
                if eventName == "hud_click" then
                    return window.elements[i].onClick(window, window.elements[i], eventName, address, x, y, button, name)
                elseif eventName == "hud_drag" then
                    return window.elements[i].onDrag(window, window.elements[i], eventName, address, x, y, button, name)
                end
            elseif button == 1 then
                if eventName == "hud_click" then
                    return window.elements[i].onClickRight(window, window.elements[i], eventName, address, x, y, button, name)
                elseif eventName == "hud_drag" then
                    return window.elements[i].onDragRight(window, window.elements[i], eventName, address, x, y, button, name)
                end
            end
        end
    end
    --No element was clicked, handle window clicks
    if button == 0 then --Left click
        if eventName == "hud_drag" then
            if window.options.movingEnabled and y >= window.position.y - 6 and y <= window.position.y + 10 then
                window.position = {x = x - window.xOffset, y = y - window.yOffset}
                for _, element in ipairs(window.elements) do
                    log("Moving")
                    element.move(window, element)
                end
            end
        elseif eventName == "hud_click" then
            if y >= window.position.y - 1 and y <= window.position.y + 6 then
                window.xOffset = x - window.position.x
                window.yOffset = y - window.position.y
            end
        end
    elseif button == 1 and eventName == "touch" then --Right click
        --Context menu?
    end
end

---@param owner string
---@param name string
---@param size Coordinate2D
---@param position Coordinate2D
function hudWindowClass.create(owner, name, size, position)
    local window = {
        name = name,
        size = size,
        position = position,
        owner = owner,
        glasses = nil,
        elements = {},
        onClick = onClick,
        options = {
            movingEnabled = false,
            closeOnFocusLoss = true
        }
    }
    -------------------------------------------
    local function remove()
        if window.elements then
            for i, element in ipairs(window.elements) do
                element.remove(window, element)
            end
            glassManager.detach(window)
            moduleManager.detach(window)
            window = {}
        end
    end
    window.remove = remove
    -------------------------------------------
    ---@param options table
    local function setOptions(options)
        window.options = options
        return window
    end
    window.setOptions = setOptions
    -------------------------------------------
    local function enableMovement()
        window.options.movingEnabled = true
    end
    window.enableMovement = enableMovement
    -------------------------------------------
    local function closeOnFocusLoss()
        return window.options.closeOnFocusLoss
    end
    window.closeOnFocusLoss = closeOnFocusLoss
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
    local function update(tick)
        for _, element in ipairs(window.elements) do
            element.update(window, element, tick)
        end
    end
    window.update = update
    -------------------------------------------
    local function init()
        window.glasses = glassManager.getGlassProxy(window.owner)
        if window.glasses then
            for _, element in ipairs(window.elements) do
                element.init(window, element)
            end
        end
    end
    window.init = init
    -------------------------------------------
    return window
end

return hudWindowClass