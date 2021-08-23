-- Import section

local uptime = require("computer").uptime
local maxWidth = (require("component").gpu.maxResolution())
local scalesInSeconds = require("configuration.constants").scalesInSeconds

--

local history = {}
local lastTime = uptime()

local function exec(powerLevel)
    table.insert(history[0], 1, powerLevel)
    local thisTime = uptime()

    if thisTime - lastTime > 0 then
        for index = 2, #scalesInSeconds do
            local pastScale = scalesInSeconds[index - 1]
            local currentScale = scalesInSeconds[index]

            local mean = 0
            if pastScale == 0 then
                for time = 1, #history[0] do
                    mean = mean + history[pastScale][time] / #history[0]
                end
            else
                for time = 1, currentScale do
                    mean = mean + (history[pastScale][time] or 0) / currentScale
                end
            end

            table.insert(history[currentScale], 1, mean)
            if #history[currentScale] == maxWidth then
                history[currentScale][maxWidth] = nil
            end
        end

        lastTime = thisTime
        history[0] = {}
    end
end

return exec
