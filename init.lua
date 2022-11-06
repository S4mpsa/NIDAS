local event = require('event')
local computer = require('computer')
event.listen('interrupted', function()
    computer.shutdown(true)
end)

local shell = require('shell')
shell.execute('clear')

local component = require('component')
if component.redstone then
    component.redstone.setWakeThreshold(1)
end

local gui = require('gui')
local guiCoroutine = coroutine.create(gui)

local infusionModule = require('modules.infusion')
local activeModules = { infusionModule }

local modules = {}
for i, activeModule in pairs(activeModules) do
    modules[i] = {
        name = activeModule.name,
        coreCoroutine = coroutine.create(activeModule.core),
        gui = activeModule.gui,
        guiReturnValue = {}
    }
end

while true do
    for _, module in ipairs(modules) do
        local coreReturn = { coroutine.resume(
            module.coreCoroutine,
            table.unpack(module.guiReturnValue)
        ), }
        table.remove(coreReturn, 1)
        module.guiReturnValue = { coroutine.resume(
            guiCoroutine,
            module.name,
            module.gui(table.unpack(coreReturn))
        ) }
    end
    ---@diagnostic disable-next-line: undefined-field
    os.sleep(0)
end
