-- Import section

local component = require("component")
local modem = component.modem
local serialization = require("serialization")
local event = require("event")

local findMatchingPattern = require("modules.infusion.find-matching-pattern")

local constants = require("configuration.constants")
local portNumber = constants.machineStatusPort

-- local namespace = {
--     infusionData = {},
--     knownAltars = {},
--     recipes = {inputs = {}, outputs = {}}
-- }
local infusion = {}

-- --

-- function namespace.save()
--     local file = io.open("/home/NIDAS/settings/infusion-data", "w")
--     file:write(serialization.serialize(namespace.infusionData))
--     file:close()
--     file = io.open("/home/NIDAS/settings/known-altars", "w")
--     file:write(serialization.serialize(namespace.knownAltars))
--     file:close()
--     file = io.open("/home/NIDAS/settings/known-recipes", "w")
--     file:write(serialization.serialize(namespace.powerHistory))
--     file:close()
-- end

-- local function load()
--     local file = io.open("/home/NIDAS/settings/infusion-data", "r")
--     if file then
--         namespace.infusionData = serialization.unserialize(file:read("*a")) or {}
--         file:close()
--     end
--     file = io.open("/home/NIDAS/settings/known-altars", "r")
--     if file then
--         namespace.knownAltars = serialization.unserialize(file:read("*a")) or {}
--         file:close()
--     end
--     file = io.open("/home/NIDAS/settings/known-recipes", "r")
--     if file then
--         namespace.recipes = serialization.unserialize(file:read("*a")) or {inputs = {}, outputs = {}}
--         file:close()
--     end
-- end
-- load()

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

local request
local savingInterval = 500
local savingCounter = savingInterval
function infusion.update()
    if not request or request.isDone() or request.isCanceled() then
        local itemsInChest = {}
        -- Adds all items in the chest connected through the storage bus to the list
        for item in component.me_interface.allItems() do
            if item.size > 0 then
                table.insert(itemsInChest, item)
            end
        end

        local pattern = findMatchingPattern(itemsInChest)
        if pattern then
            local patternOutput
            for _, output in ipairs(pattern.outputs) do
                if output then
                    patternOutput = output
                    break
                end
            end

            local craftable = component.me_interface.getCraftables({label = patternOutput.name})[1]
            print("Crafting " .. craftable.getItemStack().label)
            -- TODO: Check for the required essentia
            request = craftable.request()

            local isCancelled, reason = request.isCanceled()
            if isCancelled then
                print("Request cancelled.")
                print(reason)
            end
        end
    end

    if savingCounter == savingInterval then
        -- namespace.save()
        savingCounter = 0
    end
    savingCounter = savingCounter + 1
    -- return namespace.recipes
end

return infusion
