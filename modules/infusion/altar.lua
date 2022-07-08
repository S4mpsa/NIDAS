local component = require("component")
local tileEntity = require("core.tile-entity")

---@class altar: tileEntity
local altar = {componentType = 'blockstonedevice_2'}

tileEntity.addType(altar.componentType, 'TC4 altar')

---Creates a new Altar object
---@param address string
---@param location coordinates
---@return altar
function altar.new(address, location)
    if not component.type(address) == altar.componentType then
        error("Wrong component type! \
        " .. 'Expected "' .. altar.componentType .. '" and got "' ..
                  component.type(address) .. '".')
    end

    ---@type altar
    local self = tileEntity.new(address, location)

    local proxy = component.proxy(address)

    function self.update() return {aspects = proxy.getAspects()} end

    return self
end

return altar
