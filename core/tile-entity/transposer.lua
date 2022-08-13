local TileEntity = require("core.tile-entity")
local inventory = require("core.tile-entity.inventory")

---@class Transposer: Inventory
---@field name string
---@field size number
local Transposer = { entityType = 'transposer' }

---Creates a new Inventory object
---@param address string
---@param location Coordinates
---@param transposerSide number index 0
---@return Transposer
function Transposer.new(address, location, transposerSide)
    ---@type Transposer
    local self = inventory.new(address, location, transposerSide, Transposer.entityType)
    return self
end

TileEntity.addType(Transposer.entityType, Transposer)

return Transposer
