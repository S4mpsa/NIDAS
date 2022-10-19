local component = require('component')
local TileEntity = require('core.tile-entity')
local Essentia = require('modules.infusion.core.dtos.essentia')

---@class MeInterface: TileEntity
local MeInterface = { entityType = 'me_interface' }

---Creates a new MeInterface object
---@param address string
---@param location Coordinates
---@return MeInterface
function MeInterface.new(address, location)
    ---@type MeInterface
    local self = TileEntity.bind(address, location)

    local proxy = component.proxy(address)

    function self.getStoredEssentia()
        return Essentia.new(proxy.getEssentiaInNetwork())
    end

    ---Requests a craft for patternItem and returns that craft
    ---@param patternItem PatternItem | Essentia
    ---@return Craft
    function self.requestCraft(patternItem)
        local filter
        if patternItem.amount then
            filter = { aspect = patternItem.name }
        else
            filter = { label = patternItem.name }
        end
        local craftable = proxy.getCraftables(filter)[1]
        if not craftable then
            error('No craftable with label ' .. patternItem.name .. ' found.')
        end
        return craftable.request(patternItem.amount or patternItem.count or 1)
    end

    ---Returns the first match for an item in the ME network with a given itemName
    ---@param itemName string
    ---@return StoredItem
    function self.getItem(itemName)
        return proxy.getItemsInNetwork({ label = itemName })[1]
    end

    ---Returns all patterns stored in the meInterface
    ---@return Pattern[]
    function self.getPatterns()
        ---@type Pattern
        local patterns = {}
        for slot = 1, 36 do
            local proxyPattern = proxy.getInterfacePattern(slot)
            if proxyPattern then
                table.insert(
                    patterns,
                    {
                        inputs = proxyPattern.inputs,
                        outputs = proxyPattern.outputs
                    }
                )
            end
        end
        return patterns
    end

    return self
end

TileEntity.addType(MeInterface.entityType, MeInterface)

return MeInterface
