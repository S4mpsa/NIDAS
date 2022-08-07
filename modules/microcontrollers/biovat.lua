local t = component.proxy(component.list("transposer")())
local r = component.proxy(component.list("redstone")())

local level = t.getTankLevel(1)
local max = t.getTankCapacity(1)
if level/max > 0.5 then
    t.transferFluid(1, 0, level - max / 2)
end
r.setOutput({0, 15, 15, 15, 15})
for i = 1, 20, 1 do
    computer.pullSignal(0.05)
end
r.setOutput({0, 0, 0, 0, 0})
r.setWakeThreshold(1)