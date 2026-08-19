local data = require("core.lib.data")

local moduleManager = {}

local moduleData = {}
local running = false

local moduleUpdateQueue = {}
local messageUpdateQueue = {}

function moduleManager.addPeriodic(identifier, func, rate)
    messageUpdateQueue[identifier] = {func = func, rate = rate}
end

function moduleManager.removePeriodic(identifier)
    messageUpdateQueue[identifier] = nil
end

function moduleManager.listPeriodic()
    return messageUpdateQueue
end

function moduleManager.attach(module, saveConfig)
    if saveConfig == nil then saveConfig = true else saveConfig = false end
    if saveConfig == true then
        table.insert(moduleData, {
            owner = module.data.window.owner,
            name = module.data.window.name,
            x = module.data.window.position.x,
            y = module.data.window.position.y,
            width = module.data.window.size.x,
            height = module.data.window.size.y
        })
        data.save("moduleData", moduleData)
    end
    table.insert(moduleUpdateQueue, module)
end

function moduleManager.detach(module)
    for i, candidate in ipairs(moduleData) do
        if module.data ~= nil then
            if module.data.window.name == candidate.name then
                table.remove(moduleData, i)
                data.save("moduleData", moduleData)
                return
            end
        end
    end
    for i, candidate in ipairs(moduleUpdateQueue) do
        if module.name == candidate.name then
            table.remove(moduleUpdateQueue, i)
            return
        end
    end
end

function moduleManager.resume()
    running = true
end


function moduleManager.pause()
    running = false
end

local tick = 0
local function update()
    while running do
        componentManager.update()
        tick = tick + 1
        for _, module in ipairs(moduleUpdateQueue) do
            module.update(tick)
        end
        for _, periodic in pairs(messageUpdateQueue) do
            if tick % periodic.rate == 0 then
                periodic.func()
            end
        end
        if tick == 20 then
            tick = 0
        end
        os.sleep()
    end
end

function moduleManager.init()
    moduleData = data.load("moduleData")
    if moduleData ~= nil then
        for _, module in ipairs(moduleData) do
            glassManager.setActivePlayer(module.owner)
            local moduleWindow = glassManager.create(module.owner, module.name,
                {x=module.width, y=module.height},
                {x=module.x, y=module.y})
            moduleWindow.options.closeOnFocusLoss = false
            local moduleWidget = powerDisplayModule(moduleWindow)

            table.insert(moduleUpdateQueue, moduleWidget)
        end
    else
        moduleData = {}
    end
    for _, module in ipairs(moduleUpdateQueue) do
        module.load()
        module.init()
    end
    moduleManager.resume()
    update()
end

return moduleManager