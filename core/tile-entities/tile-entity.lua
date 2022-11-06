local component = require("component")
local event = require("event")

---@type TileEntity
local TileEntity = {}

local knownEntities = {}
local knownEntityClasses = {}

---comment
---@param componentName string
---@param class TileEntity
function TileEntity.addType(componentName, class)
    knownEntityClasses[componentName] = class
end

function TileEntity.listKnownEntities()
    return pairs(knownEntities)
end

local function getEntityClass(entityType)
    return knownEntityClasses[entityType]
end

function TileEntity.refreshKnownEntitiesList()
    for address, entityType in component.list() do
        if getEntityClass(entityType) then
            knownEntities[address] = component.proxy(address)
        end
    end
end

---Binds a TileEntity object
---@param address string
---@param location Coordinates
---@return TileEntity
function TileEntity.bind(address, location, entityType)
    if not component.type(address) == entityType then
        error("Wrong component type! \
        " .. 'Expected "' .. entityType .. '" and got "' .. component.type(address) .. '".')
    end

    ---@class TileEntity
    ---@field entityType string
    local self = {}
    self.address = address
    self.location = location

    local proxy = component.proxy(address)
    knownEntities[address] = proxy

    return self
end

---Creates a new TileEntity object
---@param address string
---@param location Coordinates
---@param ... any
---@return TileEntity
function TileEntity.new(address, location, entityType, ...)
    if not getEntityClass(entityType) then
        error('Unknown component type!')
    end
    return knownEntityClasses[entityType].new(address, location, ...)
end

-- event.listen("component_added", function(_, address, entityType)
--     if getEntityClass(entityType) then
--         knownEntities[address] = knownEntities[address] or knownEntityClasses[entityType].new(address)
--     end
-- end)

event.listen("component_removed", function(_, address)
    knownEntities[address] = nil
end)

return setmetatable(TileEntity, {
    __index = function(_, entityType)
        return getEntityClass(entityType)
    end,
})
