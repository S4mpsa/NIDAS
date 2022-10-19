local component = require('component')
local Altar = require('modules.infusion.core.entities.altar')
local Matrix = require('modules.infusion.core.entities.matrix')
local MeInterface = require('modules.infusion.core.entities.me-interface')
local RedstoneIO = require('core.tile-entity.redstone-io')
local transposer = require('core.tile-entity.transposer')

local altar = Altar.new(
    component[RedstoneIO.entityType].address,
    component[RedstoneIO.entityType].address,
    component[Matrix.entityType].address,
    component[MeInterface.entityType].address,
    component[transposer.entityType].address
)
local function getKnownAltars()
    local altars = { altar }

    return altars
end

return getKnownAltars
