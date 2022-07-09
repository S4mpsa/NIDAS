local component = require("component")
local tileEntity = require("core.tile-entity")

---@class matrix: tileEntity
local matrix = {componentType = 'blockstonedevice_2'}

tileEntity.addType(matrix.componentType, matrix)

---Creates a new matrix object
---@param address string
---@param location coordinates
---@return matrix
function matrix.new(address, location)
    if not component.type(address) == matrix.componentType then
        error("Wrong component type! \
        " .. 'Expected "' .. matrix.componentType .. '" and got "' ..
                  component.type(address) .. '".')
    end

    ---@type matrix
    local self = tileEntity.bind(address, location)

    local proxy = component.proxy(address)

    function self.update() return {aspects = proxy.getAspects()} end

    return self
end

return matrix
