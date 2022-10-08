local constants = require('modules.infusion.constants').coreStatuses
local lastLog = ''
local function logger(currentLog)
    if currentLog then
        if lastLog ~= currentLog then
            print(currentLog)
            lastLog = currentLog
        end
    end
end

local infusionCoroutine = coroutine.create(function(...)
    local args = ...
    while true do
        local message = args[2]
        if message == constants.no_infusions then
            logger('All altars are idle')
        elseif message == constants.infusion_start then
            logger('Placing items for "' .. args[3] .. '" on the pedestals')
        elseif message == constants.waiting_on_matrix then
            logger('Waiting for matrix activation')
        elseif message == constants.missing_essentia then
            logger(
                'Missing essentia to infuse "'
                    .. args[3]
                    .. '":\n'
                    .. tostring(args[4])
                )
        elseif message == constants.waiting_on_essentia then
            logger(
                'Infusing "'
                    .. args[3]
                    .. '":\n'
                    .. tostring(args[4])
                )
        elseif message ~= 'dead' then
            logger(table.unpack(args))
        end
        args = coroutine.yield()
    end
end)

return { 'Infusion automation', infusionCoroutine }
