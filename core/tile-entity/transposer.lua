local tileEntity = require("core.tile-entity")
local inventory = require("core.tile-entity.inventory")

---@class transposer: inventory
---@field name string
---@field size number
local transposer = {componentType = 'transposer'}

---Creates a new inventory object
---@param address string
---@param location coordinates
---@param transposerSide number index 0
---@return transposer
function transposer.new(address, location, transposerSide)
    ---@type transposer
    local self = inventory.new(address, location, transposerSide)
    return self
end

tileEntity.addType(transposer.componentType, transposer)

return transposer
