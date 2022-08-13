local component = require("component")
local TileEntity = require("core.tile-entity")
local sides = require('sides')

---@class Inventory: TileEntity
---@field name string
---@field size number
local Inventory = { entityType = 'inventory_controller' }

local relativeSidePositions = {
    [sides.down] = 'below',
    [sides.up] = 'above',
    [sides.north] = 'north of',
    [sides.south] = 'south of',
    [sides.west] = 'west of',
    [sides.east] = 'east of',
}

---Creates a new Inventory object
---@param address string
---@param location Coordinates
---@param controllerSide number index 0
---@return Inventory
function Inventory.new(address, location, controllerSide, overridingEntityType)
    ---@type Inventory
    local self = TileEntity.bind(address, location, overridingEntityType or Inventory.entityType)

    local proxy = component.proxy(address)

    function self.updateControllerSide(newSide)
        if not newSide then
            for i = 0, 5 do
                self.name = proxy.getInventoryName(i)
                if self.name then
                    newSide = i
                    break
                end
            end
        end
        controllerSide = newSide
        self.name = proxy.getInventoryName(controllerSide)
    end

    self.updateControllerSide(controllerSide)
    if not self.name then
        error("No inventory " .. relativeSidePositions[controllerSide] .. " the given transposer.")
    end
    self.size = proxy.getInventorySize(controllerSide)

    function self.compareStacks(slot1, slot2)
        return proxy.compareStacks(controllerSide, slot1, slot2)
    end

    ---@param otherControllerSide side
    ---@param itemCount number
    ---@param slot number
    ---@param otherSlot number
    ---@return number transferredCount
    function self.transferItem(otherControllerSide, itemCount, slot, otherSlot)
        if not otherControllerSide then
            for i = 0, 5 do
                if i ~= controllerSide and proxy.getInventoryName(i) then
                    otherControllerSide = i
                    break
                end
            end
        end
        return proxy.transferItem(controllerSide, otherControllerSide, itemCount, slot or 1, otherSlot or 1)
    end

    ---@param slot number index 1
    ---@return ItemStack
    function self.getStackInSlot(slot)
        ---@type ItemStack
        local stack = proxy.getStackInSlot(controllerSide, slot)
        stack.maxStackSize = proxy.getSlotMaxStackSize(controllerSide, slot)
        return stack
    end

    local content = {}
    function self.getContent()
        content = proxy.getAllStacks(controllerSide)
        for i in ipairs(content) do
            content[i].maxStackSize = proxy.getSlotMaxStackSize(controllerSide, i)
        end
    end

    return self
end

TileEntity.addType(Inventory.entityType, Inventory)

return Inventory
