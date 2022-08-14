local component = require("component")
local TileEntity = require("core.tile-entity")

---@class Matrix: TileEntity
local Matrix = { entityType = 'blockstonedevice_2' }

---Creates a new Matrix object
---@param address string
---@param location Coordinates
---@return Matrix
function Matrix.new(address, location)
    ---@type Matrix
    local self = TileEntity.bind(address, location)

    local proxy = component.proxy(address)

    ---Gets the essentia a matrix still requires for the ongoing infusion
    ---@return Essentia[]
    function self.read()
        return proxy.getAspects()
    end

    return self
end

TileEntity.addType(Matrix.entityType, Matrix)

return Matrix
