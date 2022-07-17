local component = require("component")
local tileEntity = require("core.tile-entity")

local relativeSidePositions = {
    [0] = 'below',
    'above',
    'north of',
    'south of',
    'west of',
    'east of'
}

---@class inventory: tileEntity
---@field name string
---@field size number
local inventory = {componentType = 'inventory_controller'}

---Creates a new inventory object
---@param address string
---@param location coordinates
---@param controllerSide number index 0
---@return inventory
function inventory.new(address, location, controllerSide)
    ---@type inventory
    local self = tileEntity.bind(address, location)

    local proxy = component.proxy(address)

    if not controllerSide then
        for i = 0, 5 do
            self.name = proxy.getInventoryName(i)
            if self.name then
                controllerSide = i
                break
            end
        end
    end
    self.name = proxy.getInventoryName(controllerSide)
    if not self.name then
        error("No inventory " .. relativeSidePositions[controllerSide] ..
                  " the given transposer.")
    end
    self.size = proxy.getInventorySize(controllerSide)

    function self.compareStacks(slot1, slot2)
        return proxy.compareStacks(controllerSide, slot1, slot2)
    end
    function self.transferItem(otherTransposerSide, itemCount, slot, otherSlot)
        return proxy.transferItem(controllerSide, otherTransposerSide,
                                  itemCount, slot, otherSlot)
    end

    ---@param slot number index 1
    ---@return itemStack
    function self.getStackInSlot(slot)
        ---@type itemStack
        local stack = proxy.getStackInSlot(controllerSide, slot)
        stack.maxStackSize = proxy.getSlotMaxStackSize(controllerSide, slot)
        return stack
    end

    local content = {}
    local function getContent()
        content = proxy.getAllStacks(controllerSide)
        for i in ipairs(content) do
            content[i].maxStackSize = proxy.getSlotMaxStackSize(controllerSide,
                                                                i)
        end
    end

    function self.update() return {content = getContent()} end

    return self
end

tileEntity.addType(inventory.componentType, inventory)

return inventory
