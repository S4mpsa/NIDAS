--local t = component.proxy(component.list("transposer")())
--local r = component.proxy(component.list("redstone")())

local component = require("component")
local t = component.transposer
local r = component.redstone

local equipped = t.getStackInSlot(1, 39)
if equipped then
    if equipped.damage > 3 then
        local chargeSlot = -1
        local retrieveSlot = -1
        for i = 1, t.getInventorySize(0), 1 do
            local item = t.getStackInSlot(0, i)
            if item then
                if item.label == "GraviChestPlate" then
                    retrieveSLot = i
                end
            else
                chargeSlot = i
            end
            if chargeSlot > 0 and retrieveSlot > 0 then
                print(chargeSlot)
                print(retrieveSlot)
                t.transferItem(1, 0, 1, 39, chargeSlot) --Move to charger
                t.transferItem(0, 1, 1, retrieveSlot, 39)
                break
            end
        end
    end
end
r.setWakeThreshold(1)