-- Import section

local uptime = require("computer").uptime
local maxWidth = (require("component").gpu.maxResolution())
local scalesInSeconds = require("configuration.constants").scalesInSeconds

--

local lastTime = uptime()

local function setSavePowerHistory(server)
    local function savePowerHistory(powerLevel)
        table.insert(server.history[0], 1, powerLevel)
        local thisTime = uptime()

        if thisTime - lastTime > 0 then
            for index = 2, #scalesInSeconds do
                local pastScale = scalesInSeconds[index - 1]
                local currentScale = scalesInSeconds[index]

                local mean = 0
                if pastScale == 0 then
                    for time = 1, #server.history[0] do
                        mean = mean + server.history[pastScale][time] / #server.history[0]
                    end
                else
                    for time = 1, currentScale do
                        mean = mean + (server.history[pastScale][time] or 0) / currentScale
                    end
                end

                table.insert(server.history[currentScale], 1, mean)
                if #server.history[currentScale] == maxWidth then
                    server.history[currentScale][maxWidth] = nil
                end
            end

            lastTime = thisTime
            server.history[0] = {}
        end
    end
    return savePowerHistory
end

return setSavePowerHistory
