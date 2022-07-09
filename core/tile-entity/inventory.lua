local component = require("component")
local tileEntity = require("core.tile-entity")

---@class inventory: tileEntity
---@field name string
---@field size number
local inventory = {}

---Creates a new inventory object
---@param address string
---@param location coordinates
---@return inventory
function inventory.new(address, location)
    ---@type inventory
    local self = tileEntity.bind(address, location)

    local proxy = component.proxy(address)
    self.name = proxy.getInventoryName()
    self.size = proxy.getInventorySize()

    self.compareStacks = proxy.compareStacks
    self.transferStack = proxy.transferStack

    function self.getStackInSlot(slot)
        ---@type itemStack
        local stack = proxy.getStackInSlot(slot)
        stack.maxStackSize = proxy.getSlotMaxStackSize(slot)
    end

    local content = {}
    local function getContent()
        content = proxy.getAllStacks()
        for i in ipairs(content) do
            content[i].maxStackSize = proxy.getSlotMaxStackSize(i)
        end
    end

    function self.update() return {content = getContent()} end

    return self
end

return inventory
