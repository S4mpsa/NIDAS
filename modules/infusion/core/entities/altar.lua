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
    self.id = matrixAddress

    local claw = Redstone.new(clawAddress, location, nil, { sides.bottom, sides.top })
    local essentiaProvider = Redstone.new(essentiaProviderAddress, location, { sides.top })
    local matrix = Matrix.new(matrixAddress, location)
    local meInterface = MeInterface.new(meInterfaceAddress, location)
    local transposer = Transposer.new(transposerAddress, location)

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
        essentiaProvider.deactivate()
    end

    function self.unblockEssentiaProvider()
        essentiaProvider.deactivate()
        essentiaProvider.activate()
    end

    function self.retrieveCraftedItem(count)
        for _ = 1, (count or 1) do
            transposer.transferItem()
        end
    end

    function self.getPatterns()
        return meInterface.getPatterns()
    end

    ---@param patternItem PatternItem
    ---@return Craft
    function self.requestCraft(patternItem)
        return meInterface.requestCraft(patternItem)
    end

    ---@param missingEssentia Essentia[]
    ---@return Craft[]
    function self.requestEssentia(missingEssentia)
        local essentiaCrafts = {}
        for _, essentia in ipairs(missingEssentia) do
            table.insert(essentiaCrafts, meInterface.requestCraft(essentia))
        end
        return essentiaCrafts
    end

    function self.getStoredEssentia()
        return meInterface.getStoredEssentia()
    end

    ---Gets a stored item with the specified `itemName`
    ---@param itemName string
    ---@return StoredItem
    function self.getItem(itemName)
        return meInterface.getItem(itemName)
    end

    ---comment
    ---@return ItemStack
    function self.getPedestalItem()
        return transposer.getStackInSlot(1)
    end

    return self
end

return Altar
