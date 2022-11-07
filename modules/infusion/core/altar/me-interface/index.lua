local component = require('component')
local MeInterface = require('core.tile-entities.me-interface')
local Essentia = require('modules.infusion.core.altar.matrix.essentia')

---@type MagicalMeInterface
local MagicalMeInterface = { entityType = MeInterface.entityType }

---Creates a new MeInterface object adapted to work with essentia
---@return MagicalMeInterface
function MagicalMeInterface.new(address, location)
    ---@class MagicalMeInterface: MeInterface
    local self = MeInterface.new(address, location)

    local proxy = component.proxy(address)

    function self.getStoredEssentia()
        return Essentia.new(proxy.getEssentiaInNetwork())
    end

    return self
end

return MagicalMeInterface
