local coreCoroutine = require('modules.infusion.core')
local guiCoroutine = require('modules.infusion.gui')

while true do
    local coreReturn = { coroutine.resume(coreCoroutine[2]) }
    coroutine.resume(guiCoroutine[2], coreReturn)
    ---@diagnostic disable-next-line: undefined-field
    os.sleep(0)
end
