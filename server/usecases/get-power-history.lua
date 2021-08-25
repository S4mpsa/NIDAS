-- Import section

local scalesInSeconds = require("configuration.constants").scalesInSeconds

--

local function setGetPowerHistory(server)
    local function getPowerHistory(scale)
        local found = false
        for _, scaleInSeconds in ipairs(scalesInSeconds) do
            if scale == scaleInSeconds then
                found = true
                break
            end
        end
        if not found then
            error("Invalid scale: " .. tostring(scale), 2)
        end

        return server.powerHistory[scale]
    end
    return getPowerHistory
end

return setGetPowerHistory
