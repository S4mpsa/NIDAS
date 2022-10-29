local component = require("component")
local TileEntity = require("core.tile-entity")

local ON = 15

---@type RedstoneIO
local RedstoneIO = { entityType = 'redstone' }

---Creates a new RedstoneIO object
---@param address string
---@param location Coordinates
---@return RedstoneIO
function RedstoneIO.new(address, location, connectedSides, disconnectedSides)
    ---@class RedstoneIO: TileEntity
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

TileEntity.addType(RedstoneIO.entityType, RedstoneIO)

return RedstoneIO
