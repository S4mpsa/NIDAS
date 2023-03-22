---Repository for graphical elements
local component = require("component")
local gpu = component.gpu

local elements = {}
----------------------------------------------------------------------
elements.border = require("core.graphics.elements.decorative.border")
elements.background = require("core.graphics.elements.decorative.background")
elements.title = require("core.graphics.elements.decorative.title")
elements.singleLineText = require("core.graphics.elements.decorative.singleLineText")
elements.closeButton = require("core.graphics.elements.functional.closeButton")
elements.smallButton = require("core.graphics.elements.functional.smallButton")
elements.largeButton = require("core.graphics.elements.functional.largeButton")
elements.textField = require("core.graphics.elements.functional.textField")
elements.numberField = require("core.graphics.elements.functional.numberField")
elements.checkbox = require("core.graphics.elements.functional.checkbox")
elements.slider = require("core.graphics.elements.functional.slider")
elements.colourSelector = require("core.graphics.elements.functional.colourSelector")
----------------------------------------------------------------------


---Element "class" used to implement functionality to windows.
---@param position Coordinate2D
---@param size Coordinate2D
---@return table
function exampleElement(position, size)

    local function draw(window, element)
        --Draw is called when the window if updated, and should render the element directly on screen. The buffer is always on the correct window.
    end
    local function onClick(window, element, eventName, address, x, y, button, name)
        --Called when the element is clicked with the left button.
        return true
    end
    local function onClickRight(window, element, eventName, address, x, y, button, name)
        --Called when the element is clicked with the right button.
        return true
    end
    local function onDrag(window, element, eventName, address, x, y, button, name)
        --Called when the element is dragged over with the left button.
        return true
    end
    local function onDragRight(window, element, eventName, address, x, y, button, name)
        --Called when the element is dragged over with the right button.
        return true
    end

    local element = {
        size = size,
        position = position,
        onClick = onClick,
        onClickRight = onClickRight,
        onDrag = onDrag,
        onDragRight = onDragRight,
        draw = draw,
        data = {} --Data should have all the variables that are used by the element. It can be accessed from elsewhere by the return value.
    }

    return element
end

return elements