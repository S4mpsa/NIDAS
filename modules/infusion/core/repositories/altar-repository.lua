local component = require('component')
local Altar = require('modules.infusion.core.aggregates.altar')
local Matrix = require('modules.infusion.core.entities.matrix')
local MeInterface = require('core.tile-entities.me-interface')
local RedstoneIO = require('core.tile-entities.redstone-io')
local Transposer = require('core.tile-entities.transposer')

local AltarRepository = {}
local altar = Altar.new(
    component[RedstoneIO.entityType].address,
    component[RedstoneIO.entityType].address,
    component[Matrix.entityType].address,
    component[MeInterface.entityType].address,
    component[Transposer.entityType].address
)

---@return Altar[]
function AltarRepository.getAll()
    local altars = { altar }

    return altars
end

return AltarRepository
