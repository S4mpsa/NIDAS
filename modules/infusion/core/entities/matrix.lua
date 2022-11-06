local component = require('component')
local TileEntity = require('core.tile-entities.tile-entity')
local Essentia = require('modules.infusion.core.dtos.essentia')

---@type Matrix
local Matrix = { entityType = 'blockstonedevice_2' }

---Creates a new Matrix object
---@param address string
---@param location Coordinates
---@return Matrix
function Matrix.new(address, location)
    ---@class Matrix: TileEntity
    local self = TileEntity.bind(address, location)

    local proxy = component.proxy(address)

    ---Gets the essentia a matrix still requires for the ongoing infusion
    ---@return Essentia[] | nil
    function self.read()
        ---@type Essentia | nil
        local aspects = proxy.getAspects().aspects
        return Essentia.new(aspects)
    end

    return self
end

TileEntity.addType(Matrix.entityType, Matrix)

return Matrix
