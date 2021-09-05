-- Import section

local component = require("component")
local modem = component.modem
local serialization = require("serialization")
local event = require("event")

local findMatchingPattern = require("modules.infusion.find-matching-pattern")
local hasEnoughEssentia = require("modules.infusion.check-required-essentia")
local getRequiredEssentia = require("modules.infusion.get-required-essentia")
local getFreeCPU = require("modules.infusion.get-free-cpu")

local constants = require("configuration.constants")
local portNumber = constants.machineStatusPort

local namespace = {
    --     infusionData = {},
    --     knownAltars = {},
    recipes = {}
}
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

-- Finds any pedestal
if component.transposer then
    for i = 0, 5 do
        local inventoryName = component.transposer.getInventoryName(i)
        if inventoryName == "tile.blockStoneDevice" then
            infusion.centerPedestalNumber = i
        elseif inventoryName then
            infusion.outputSlotNumber = i
        end
    end
end

local request
local savingInterval = 500
local savingCounter = savingInterval
function infusion.update()
    if (not request or request.isDone() or request.isCanceled()) and getFreeCPU(component.me_interface.address) then
        local itemsInChest = {}
        -- Adds all items in the chest connected through the storage bus to the list
        for item in component.me_interface.allItems() do
            if item.size > 0 then
                table.insert(itemsInChest, item)
            end
        end

        local pattern = findMatchingPattern(itemsInChest)
        if pattern then
            local label
            for _, output in ipairs(pattern.outputs) do
                if output.name then
                    label = output.name
                    break
                end
            end

            if not namespace.recipes[label] or hasEnoughEssentia(namespace.recipes[label]) then
                local craftable = component.me_interface.getCraftables({label = label})[1]
                print("Crafting " .. label)
                request = craftable.request()

                local isCancelled, reason = request.isCanceled()
                if isCancelled then
                    print("Request cancelled. Please clean up your altar if that is the case")
                    print(reason)
                    return
                end

                -- TODO: event-based non-blocking code
                -- Waits for an item to be in the center pedestal
                local itemLabel
                local item
                while not itemLabel do
                    item = component.transposer.getStackInSlot(infusion.centerPedestalNumber, 1)
                    itemLabel = item and item.label
                    os.sleep(0)
                end

                -- Starts the infusion
                component.redstone.setOutput({15, 15, 15, 15, 15, 15})

                -- Checks for the required essentia on the first time the recipe is crafted
                if not namespace.recipes[label] and not request.isCanceled() then
                    local inputs = {}
                    for _, input in ipairs(pattern and pattern.inputs or {}) do
                        -- Searches for input items in the pattern
                        if input.name then
                            table.insert(inputs, input.name)
                        end
                    end

                    namespace.recipes[label] = {
                        inputs = inputs,
                        essentia = getRequiredEssentia(component.blockstonedevice_2.address)
                    }
                    if not hasEnoughEssentia(namespace.recipes[label]) then
                        print("WARNING, NOT ENOUGH ESSENTIA!")
                        while component.transposer.getStackInSlot(infusion.centerPedestalNumber, 1) do
                            component.transposer.transferItem(infusion.centerPedestalNumber, infusion.outputSlotNumber)
                            os.sleep(0)
                        end
                        print("Removed item from the center pedestal")
                    end
                end

                -- TODO: event-based non-blocking code
                -- Waits for the item in the center pedestal to change
                while itemLabel == item.label do
                    item = component.transposer.getStackInSlot(infusion.centerPedestalNumber, 1) or {}
                    os.sleep(0)
                end

                -- Removes all items from the center pedestal
                while component.transposer.getStackInSlot(infusion.centerPedestalNumber, 1) do
                    component.transposer.transferItem(infusion.centerPedestalNumber, infusion.outputSlotNumber)
                    os.sleep(0)
                end
                component.redstone.setOutput({0, 0, 0, 0, 0, 0})

                if request.isDone() then
                    print("Done")
                else
                    print("Oh, oh...")
                    print("Removed " .. item.label .. " from the pedestal.")
                    print("But the craft for " .. label .. " is still going in the ME system.")
                end
            else
                print("Not enough essentia to craft " .. label)
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
