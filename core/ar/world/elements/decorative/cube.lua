local component = require("component")
local numUtils = require("core.lib.numUtils")


---@param position Coordinate3D
---@param colour number
---@param parameters? table
function cube(position, colour, parameters)

    local function init(anchor, element)
        local cube = anchor.glasses.addCube3D()
        local xPos = anchor.position.x + element.position.x - terminalPositions[anchor.owner].x
        local yPos = anchor.position.y + element.position.y - terminalPositions[anchor.owner].y
        local zPos = anchor.position.z + element.position.z - terminalPositions[anchor.owner].z
        cube.set3DPos(xPos, yPos, zPos)
        cube.setLookingAt(anchor.position.x, anchor.position.y, anchor.position.z)
        cube.setColor(numUtils.toRGB(element.data.colour))
        if element.data.parameters then
            if element.data.parameters.visibleThroughObjects then cube.setVisibleThroughObjects(element.data.parameters.visibleThroughObjects) end
            if element.data.parameters.alpha then cube.setAlpha(element.data.parameters.alpha) end
            if element.data.parameters.lookingAt == true then cube.setLookingAt(element.data.parameters.lookingAt) end
            if element.data.parameters.scale then cube.setScale(element.data.parameters.scale) end
        end
        element.data.widgets["cube"] = cube
    end

    local function update(window, element)

    end

    local function move(anchor, element)

    end

    local function remove(anchor, element)
        anchor.glasses.removeObject(element.data.widgets["cube"].getID())
    end

    local element = {
        position = position,
        init = init,
        update = update,
        move = move,
        remove = remove,
        data = {widgets = {}, colour = colour, parameters = parameters}
    }

    return element
end

return cube