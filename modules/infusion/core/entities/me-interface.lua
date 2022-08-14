local component = require("component")
local TileEntity = require("core.tile-entity")

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
        return proxy.getEssentiaInNetwork()
    end

    ---Requests a craft labeled craftableLabel and returns that craft
    ---@param craftableLabel string
    ---@return Craft
    function self.requestCraft(craftableLabel)
        local craftable = proxy.getCraftables({ label = craftableLabel })[1]
        if not craftable then
            error('No craftable with label ' .. craftableLabel .. ' found.')
        end
        return craftable.request()
    end

    ---Returns all patterns stored in the meInterface
    ---@return Pattern
    function self.getPatterns()
        ---@type Pattern
        local patterns = {}
        for slot = 1, 36 do
            local proxyPattern = proxy.getInterfacePattern(slot)
            if proxyPattern then
                table.insert(patterns, { inputs = proxyPattern.inputs, outputs = proxyPattern.outputs })
            end
        end
        return patterns
    end

    return self
end

TileEntity.addType(MeInterface.entityType, MeInterface)

return MeInterface
