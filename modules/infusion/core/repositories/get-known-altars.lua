local component = require('component')
local Altar = require('modules.infusion.core.entities.altar')
local Matrix = require('modules.infusion.core.entities.matrix')
local MeInterface = require('modules.infusion.core.entities.me-interface')
local Redstone = require('core.tile-entity.redstone')
local transposer = require('core.tile-entity.transposer')

local altar = Altar.new(
    component[Redstone.entityType].address,
    component[Redstone.entityType].address,
    component[Matrix.entityType].address,
    component[MeInterface.entityType].address,
    component[transposer.entityType].address
)
local function getKnownAltars()
    local altars = { altar }

    return altars
end

return getKnownAltars
