local component = require("component")
local TileEntity = require("core.tile-entity")
local sides = require('sides')

local relativeSidePositions = {
    [sides.down] = 'below',
    [sides.up] = 'above',
    [sides.north] = 'north of',
    [sides.south] = 'south of',
    [sides.west] = 'west of',
    [sides.east] = 'east of',
}

---@class Inventory: TileEntity
---@field name string
---@field size number
local Inventory = { entityType = 'inventory_controller' }

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
                if proxy.getInventoryName(5 - i) then
                    newSide = 5 - i
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

    ---@param otherControllerSide number index 0
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
        if stack then
            stack.maxStackSize = proxy.getSlotMaxStackSize(controllerSide, slot)
        end
        return stack
    end

    ---@return ItemStack[]
    function self.getContent()
        ---@type ItemStack
        local content = proxy.getAllStacks(controllerSide) or {}
        for i in ipairs(content) do
            content[i].maxStackSize = proxy.getSlotMaxStackSize(controllerSide, i)
        end
        return content
    end

    return self
end

TileEntity.addType(Inventory.entityType, Inventory)

return Inventory
