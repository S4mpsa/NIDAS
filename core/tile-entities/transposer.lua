local TileEntity = require("core.tile-entity")
local Inventory = require("core.tile-entity.inventory")


---@type Transposer
local Transposer = { entityType = 'transposer' }

---Creates a new Inventory object
---@param address string
---@param location Coordinates
---@param transposerSide number index 0
---@return Transposer
function Transposer.new(address, location, transposerSide)
    ---@class Transposer: Inventory
    local self = Inventory.new(address, location, transposerSide, Transposer.entityType)
    return self
end

TileEntity.addType(Transposer.entityType, Transposer)

return Transposer
