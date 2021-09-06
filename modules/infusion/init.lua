-- Import section

local component = require("component")
local serialization = require("serialization")

--

local namespace = {
    recipes = {},
    infusionData = {}
}
local infusion = {}

function namespace.save()
    local file = io.open("/home/NIDAS/settings/infusion-data", "w")
    file:write(serialization.serialize(namespace.infusionData))
    file:close()
    file = io.open("/home/NIDAS/settings/known-recipes", "w")
    file:write(serialization.serialize(namespace.recipes))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/infusion-data", "r")
    if file then
        namespace.infusionData = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
    file = io.open("/home/NIDAS/settings/known-recipes", "r")
    if file then
        namespace.recipes = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
end
load()

-- -- Sets up configuration menu for the infusion
-- local configure = require("modules.infusion.configure")(namespace)
-- function infusion.configure(x, y, _, _, _, page)
--     return configure(x, y, page)
-- end

function infusion.configure()
    return {}
end

-- --Sets up the event listeners for the infusion
-- require("modules.infusion.event-listen")(namespace)

local checkAndInfuse = require("modules.infusion.check-and-infuse")(namespace)

-- Finds any pedestal
pcall(
    function()
        namespace.infusionData.transposer = component.transposer
        for i = 0, 5 do
            local inventoryName = namespace.infusionData.transposer.getInventoryName(i)
            if inventoryName == "tile.blockStoneDevice" then
                namespace.infusionData.centerPedestalNumber = i
            elseif inventoryName then
                namespace.infusionData.outputSlotNumber = i
            end
        end
        return
    end
)

function infusion.update()
    -- TODO: support multiple altars, transposers, redstone I/Os, and interfaces
    checkAndInfuse()
end

return infusion
