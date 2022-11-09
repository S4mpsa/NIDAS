local shell = require('shell')
shell.execute('clear')

local event = require('event')
local computer = require('computer')
event.listen('interrupted', function()
    computer.shutdown(true)
end)

local component = require('component')
if component.redstone then
    component.redstone.setWakeThreshold(1)
end

local infusionModule = require('modules.infusion')
local navigationStack = { infusionModule }
event.listen('Return', function()
    table.remove(navigationStack)
end)

local crashCount = 0
local function wrap(f)
    local coro = coroutine.create(f)
    local function wrapped(...)
        local ret = { coroutine.resume(coro, ...) }

        local success = table.remove(ret, 1)
        if not success then
            print('Module "' .. navigationStack[#navigationStack] .. '" crashed:')
            print(table.unpack(ret))
            print('Please open a ticket on github')

            coro = coroutine.create(f)
            crashCount = crashCount + 1
            if crashCount > 5 then
                error(table.unpack(ret))
            end
        end

        ---@diagnostic disable-next-line: undefined-field
        os.sleep(0)

        return table.unpack(ret)
    end

    return wrapped
end

local gui = require('gui')
local wrappedGui = wrap(gui)

local modulesIndexes = { infusionModule }
local modules = {}
for i, moduleIndex in ipairs({ table.unpack(modulesIndexes) }) do
    modules[i] = {
        name = moduleIndex.name,
        gui = moduleIndex.gui,
        guiReturn = {},
        wrappedCore = wrap(moduleIndex.core),
    }
end

while true do
    for _, module in ipairs(modules) do
        local coreReturn = { module.wrappedCore(table.unpack(module.guiReturn)) }

        if module.name == navigationStack[#navigationStack] then
            local guiComponent = module.gui(table.unpack(coreReturn))
            modules.guiReturn = { wrappedGui(guiComponent, navigationStack) }
        end
    end
end
