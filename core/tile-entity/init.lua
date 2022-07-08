local component = require("component")
local event = require("event")

---@class tileEntity
---@field address string
---@field position coordinates
local tileEntity = {}

local knownEntities = {}
local knownEntityTypes = {}

function tileEntity.addType(componentName, description)
    knownEntityTypes[componentName] = description or componentName
end

function tileEntity.listKnownEntities() return pairs(knownEntities) end

local function isKnownType(componentType)
    for type in pairs(knownEntityTypes) do
        if componentType == type then return true end
    end
end

function tileEntity.refreshKnownEntitiesList()
    for address, componentType in component.list() do
        if isKnownType(componentType) then
            knownEntities[address] = component.proxy(address)
        end
    end
end

---Creates a new tileEntity object
---@param address string
---@param position coordinates
---@return tileEntity
function tileEntity.new(address, position)
    if not isKnownType(component.type(address)) then
        error('Unknown component type!')
    end

    ---@type tileEntity
    local self = {}
    self.address = address
    self.position = position

    local proxy = component.proxy(address)
    knownEntities[address] = proxy

    function self.update() error("I am abstract!") end

    return self
end

event.listen("component_added", function(address, componentType)
    if isKnownType(componentType) then
        knownEntities[address] = component.proxy(address)
    end
end)

event.listen("component_removed",
             function(address) knownEntities[address] = nil end)

return tileEntity
