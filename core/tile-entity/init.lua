local component = require("component")
local event = require("event")

---@class tileEntity
---@field address string
---@field location coordinates
local tileEntity = {}

local knownEntities = {}
local knownEntityTypes = {}

function tileEntity.addType(componentName, class)
    knownEntityTypes[componentName] = class
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

---Binds a tileEntity object
---@param address string
---@param location coordinates
---@return tileEntity
function tileEntity.bind(address, location)
    ---@type tileEntity
    local self = {}
    self.address = address
    self.location = location

    local proxy = component.proxy(address)
    knownEntities[address] = proxy

    function self.update() error("I am abstract!") end

    return self
end

---Creates a new tileEntity object
---@param address string
---@param location coordinates
---@param ... any
---@return tileEntity
function tileEntity.new(address, location, ...)
    if not isKnownType(component.type(address)) then
        error('Unknown component type!')
    end
    return knownEntityTypes[component.type(address)].new(address, location, ...)
end

event.listen("component_added", function(address, componentType)
    if isKnownType(componentType) then
        knownEntities[address] = component.proxy(address)
    end
end)

event.listen("component_removed",
             function(address) knownEntities[address] = nil end)

return tileEntity
