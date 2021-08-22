-- Import section

local uptime = require("computer").uptime
local maxWidth = (require("component").gpu.maxResolution())

--

local scalesInSeconds = {
    0,
    1,
    5,
    15,
    30,
    60,
    300,
    900,
    1800,
    3600
}

local history = {}
local lastTime = uptime()

local function exec(powerLevel)
    table.insert(history[0], 1, powerLevel)
    local thisTime = uptime()

    for index = 2, #scalesInSeconds do
        local pastScale = scalesInSeconds[index - 1]
        local currentScale = scalesInSeconds[index]

        if thisTime - lastTime >= currentScale then
            local historyLength = #history[pastScale]
            if pastScale ~= 0 and historyLength > currentScale then
                historyLength = currentScale
            end

            local mean = 0
            for time = 1, historyLength do
                mean = mean + history[pastScale][time] / historyLength
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
