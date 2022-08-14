local sides = require('sides')
local Matrix = require('modules.infusion.core.entities.matrix')
local MeInterface = require('modules.infusion.core.entities.me-interface')
local Redstone = require('core.tile-entity.redstone')
local Transposer = require('core.tile-entity.transposer')

---@class Altar
local Altar = {}

---Creates a new Altar object
---@param clawAddress string
---@param essentiaProviderAddress string
---@param matrixAddress string
---@param meInterfaceAddress string
---@param transposerAddress string
---@param location Coordinates
---@return Altar
function Altar.new(clawAddress,
                   essentiaProviderAddress,
                   matrixAddress,
                   meInterfaceAddress,
                   transposerAddress,
                   location)

    ---@type Altar
    local self = {}

    local claw = Redstone.new(clawAddress, location, { sides.top })
    local essentiaProvider = Redstone.new(essentiaProviderAddress, location, nil, { sides.bottom, sides.top })
    local matrix = Matrix.new(matrixAddress, location)
    local meInterface = MeInterface.new(meInterfaceAddress, location)
    local transposer = Transposer.new(transposerAddress, location)

    ---@type Craft
    local craft = {}
    function craft.isDone()
        return true
    end
    function craft.isCanceled()
        return true
    end

    ---Gets the essentia a matrix still requires for the ongoing infusion
    ---@return Essentia[]
    function self.readMatrix()
        return matrix.read()
    end

    function self.activateMatrix()
        claw.deactivate()
        claw.activate()
    end

    function self.blockEssentiaProvider()
        essentiaProvider.activate()
    end

    function self.unblockEssentiaProvider()
        essentiaProvider.deactivate()
    end

    function self.retireveCraftedItem()
        transposer.transferItem()
    end

    function self.getPatterns()
        return meInterface.getPatterns()
    end

    ---@param patternItem PatternItem
    ---@return Craft
    function self.requestCraft(patternItem)
        craft = meInterface.requestCraft(patternItem)
        return craft
    end

    ---@param missingEssentia Essentia[]
    ---@return Craft
    function self.requestEssentia(missingEssentia)
        for _, essentia in ipairs(missingEssentia) do
            craft = meInterface.requestCraft(essentia)
        end
        return craft
    end

    function self.getStoredEssentia()
        return meInterface.getStoredEssentia()
    end

    ---Tells if the altar already has an ongoing craft
    ---@return any
    function self.isBusy()
        return not (craft.isDone() or craft.isCanceled())
    end

    return self
end

return Altar
