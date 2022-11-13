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

local EventProcessor = require('core.event-processor')

local modules = require('modules')

local processor = EventProcessor.new()

local coreListener = require('core').new(modules, processor)
processor.listen('to-core', coreListener)

local otherListeners = {
    require('gui').new(modules, processor)
}
for _, listener in ipairs(otherListeners) do
    processor.listen('from-core', listener)
end

while true do
    processor.push('to-core', {})
    processor.consumeQueue()
end
