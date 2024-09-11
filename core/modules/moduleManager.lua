

local moduleManager = {}

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

function moduleManager.attach(module)
    table.insert(moduleUpdateQueue, module)
end

function moduleManager.detach(module)
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
    for _, module in ipairs(moduleUpdateQueue) do
        module.init()
    end
    moduleManager.resume()
    update()
end

return moduleManager