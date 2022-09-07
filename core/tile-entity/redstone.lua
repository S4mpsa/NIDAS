local component = require("component")
local TileEntity = require("core.tile-entity")

local ON = 15

---@class Redstone: TileEntity
local Redstone = { entityType = 'redstone' }

---Creates a new Redstone object
---@param address string
---@param location Coordinates
---@return Redstone
function Redstone.new(address, location, connectedSides, disconnectedSides)
    ---@type Redstone
    local self = TileEntity.bind(address, location)

    local sidesEnable = {}
    local sidesDisable = {}
    connectedSides = connectedSides or { 0, 1, 2, 3, 4, 5 }
    disconnectedSides = disconnectedSides or {}
    for _, side in ipairs(connectedSides) do
        sidesEnable[side] = ON
        sidesDisable[side] = 0
        for _, disconnectedSide in ipairs(disconnectedSides) do
            if disconnectedSide == side then
                sidesEnable[side] = nil
                sidesDisable[side] = nil
            end
        end
    end

    local proxy = component.proxy(address)

    function self.activate()
        proxy.setOutput(sidesEnable)
    end

    function self.deactivate()
        proxy.setOutput(sidesDisable)
    end

    return self
end

TileEntity.addType(Redstone.entityType, Redstone)

return Redstone
