-- Import section

local component = require("component")
local serialization = require("serialization")

local findMatchingPattern = require("modules.infusion.find-matching-pattern")
local checkForMissingEssentia = require("modules.infusion.check-for-missing-essentia")
local getRequiredEssentia = require("modules.infusion.get-required-essentia")
local getFreeCPU = require("modules.infusion.get-free-cpu")

--
local function printIfDebug(args)
    if DEBUG then
        print(args)
    end
end
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

-- Finds any pedestal
local transposer
pcall(
    function()
        transposer = component.transposer
        for i = 0, 5 do
            local inventoryName = transposer.getInventoryName(i)
            if inventoryName == "tile.blockStoneDevice" then
                namespace.infusionData.centerPedestalNumber = i
            elseif inventoryName then
                namespace.infusionData.outputSlotNumber = i
            end
        end
        return
    end
)

local request
local hasWarnedAboutMissingEssentia = false
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

            local missingEssentia = checkForMissingEssentia(namespace.recipes[label])
            if not namespace.recipes[label] or not missingEssentia then
                local craftable = component.me_interface.getCraftables({label = label})[1]
                printIfDebug("Crafting " .. label)
                request = craftable.request()

                local isCancelled, reason = request.isCanceled()
                if isCancelled then
                    printIfDebug("Request cancelled. Please clean up your altar if that is the case")
                    printIfDebug(reason)
                    printIfDebug()
                    return
                end

                -- TODO: event-based, non-blocking code

                -- Waits for an item to be in the center pedestal
                local itemLabel
                local item
                while not itemLabel do
                    item = transposer.getStackInSlot(namespace.infusionData.centerPedestalNumber, 1)
                    itemLabel = item and item.label
                    os.sleep(0)
                end

                -- Starts the infusion
                component.redstone.setOutput({15, 15, 15, 15, 15, 15})
                component.redstone.setOutput({0, 0, 0, 0, 0, 0})

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
                    namespace.save()

                    missingEssentia = checkForMissingEssentia(namespace.recipes[label])
                    if missingEssentia then
                        printIfDebug("WARNING, NOT ENOUGH ESSENTIA!")
                        printIfDebug("Missing:")
                        for essentia, amount in pairs(namespace.recipes[label]) do
                            printIfDebug("  " .. essentia .. ": " .. amount)
                        end
                        printIfDebug()
                        while transposer.getStackInSlot(namespace.infusionData.centerPedestalNumber, 1) do
                            transposer.transferItem(
                                namespace.infusionData.centerPedestalNumber,
                                namespace.infusionData.outputSlotNumber
                            )
                            os.sleep(0)
                        end
                        printIfDebug("Removed " .. itemLabel .. " from the center pedestal. Sorry for the flux.")
                        printIfDebug("Please cancel the craft manually.")
                        printIfDebug()
                        return
                    end
                end

                -- TODO: event-based non-blocking code
                -- Waits for the item in the center pedestal to change
                while itemLabel == item.label do
                    item = transposer.getStackInSlot(namespace.infusionData.centerPedestalNumber, 1) or {}
                    os.sleep(0)
                end

                -- Removes all items from the center pedestal
                while transposer.getStackInSlot(namespace.infusionData.centerPedestalNumber, 1) do
                    transposer.transferItem(
                        namespace.infusionData.centerPedestalNumber,
                        namespace.infusionData.outputSlotNumber
                    )
                    os.sleep(0)
                end

                if request.isDone() then
                    printIfDebug("Done")
                else
                    printIfDebug("Oh, oh...")
                    printIfDebug("Removed " .. itemLabel .. " from the pedestal.")
                    printIfDebug("But the craft for " .. label .. " is still going in the ME system.")
                    printIfDebug("Please cancel the craft manually.")
                    printIfDebug("Are you using a dummy item?")
                end
                printIfDebug()
                hasWarnedAboutMissingEssentia = false
            else
                if not hasWarnedAboutMissingEssentia then
                    printIfDebug("Not enough essentia to craft " .. label)
                    printIfDebug("Missing:")
                    for essentia, amount in pairs(missingEssentia) do
                        printIfDebug("  " .. essentia .. ": " .. amount)
                    end
                    printIfDebug()
                    hasWarnedAboutMissingEssentia = true
                end
            end
        else
            hasWarnedAboutMissingEssentia = false
        end
    end
end

return infusion
