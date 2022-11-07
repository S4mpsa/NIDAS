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

-- local theHand = require('hand')

local infusionModule = require('modules.infusion')
local modules = { --[[theHand,]] infusionModule }
local activeModuleName = infusionModule.name
for i, module in pairs(modules) do
    modules[i] = {
        name = module.name,
        coreCoroutine = coroutine.create(module.core),
        gui = module.gui,
        guiReturnValue = {}
    }
end

while true do
    for _, module in ipairs(modules) do
        ---@type any[]
        local coreReturn = { coroutine.resume(
            module.coreCoroutine,
            table.unpack(module.guiReturnValue)
        ), }
        if not table.remove(coreReturn, 1) then
            print('Module "' .. module.name .. '" crashed')
            print('Please open a ticket on github')
        end

        if module.name == activeModuleName then
            module.guiReturnValue = { coroutine.resume(
                guiCoroutine,
                module.name,
                module.gui(table.unpack(coreReturn))
            ), }
            if not table.remove(module.guiReturnValue, 1) then
                print('Module "' .. module.name .. '" crashed')
                print('Please open a ticket on github')
            end

            if table.unpack(module.guiReturnValue) == 'return' then
                print('return')
                -- activeModuleName = theHand.name
            end
        end
    end

    ---@diagnostic disable-next-line: undefined-field
    os.sleep(0)
end
