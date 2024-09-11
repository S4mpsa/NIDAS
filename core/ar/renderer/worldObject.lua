--Defines a 3D point that acts as an anchor for world elements

local component = require("component")

local worldObject = {}

---@param owner string
---@param name string
---@param position Coordinate3D
function worldObject.create(owner, name, position)
    local object = {
        name = name,
        position = position,
        owner = owner,
        glasses = nil,
        elements = {},
        options = {}
    }
    -------------------------------------------
    local function remove()
        for i, element in ipairs(object.elements) do
            element.remove()
        end
        object = {}
    end
    object.remove = remove
    -------------------------------------------
    ---@param options table
    local function setOptions(options)
        object.options = options
        return object
    end
    object.setOptions = setOptions
    -------------------------------------------
    ---@param element Element
    local function addElement(element)
        table.insert(object.elements, element)
        return object
    end
    object.addElement = addElement
    -------------------------------------------
    ---@param elements table
    local function addElements(elements)
        for _, element in ipairs(elements) do
            table.insert(object.elements, element)
        end
        return object
    end
    object.addElements = addElements
    -------------------------------------------
    local function update()
        for _, element in ipairs(object.elements) do
            element.update(object, element)
        end
    end
    object.update = update
    -------------------------------------------
    local function interact()
        --Implemented in modules
    end
    object.interact = interact
    -------------------------------------------
    local function init()
        object.glasses = glassManager.getGlassProxy(object.owner)
        if object.glasses then
            for _, element in ipairs(object.elements) do
                element.init(object, element)
            end
        end
    end
    object.init = init
    -------------------------------------------
    return object
end

return worldObject