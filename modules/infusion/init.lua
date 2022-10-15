local coreCoroutine = require('modules.infusion.core')
local guiCoroutine = require('modules.infusion.gui')

local computer = require('computer')
local event = require('event')
event.onError = print
event.listen('interrupted', function ()
    computer.shutdown(true)
end)

while true do
    local coreReturn = { coroutine.resume(coreCoroutine[2]) }
    coroutine.resume(guiCoroutine[2], coreReturn)
    ---@diagnostic disable-next-line: undefined-field
    os.sleep(0)
end
