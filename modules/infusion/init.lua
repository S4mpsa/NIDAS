local coreCoroutine = require('modules.infusion.core.init')

local lastLog = ''
local function logger(_, message, complement)
    if message then
        local currentLog = message .. tostring(complement or '')
        if lastLog ~= currentLog then
            print(currentLog)
            lastLog = currentLog
        end
    end
end

while true do
    logger(coroutine.resume(coreCoroutine[2]))
    os.sleep(0)
end
