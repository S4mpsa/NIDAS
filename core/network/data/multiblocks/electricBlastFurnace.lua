local numUtils = require("core.lib.numUtils")
local stringUtils = require("core.lib.stringUtils")
local getMaintenanceStatus = require("core.network.data.utils.getMaintenanceStatus")

local function getProxy(proxy)

    local dataProxy = {
        name = "Electric Blast Furnace",
        short = "EBF",
        proxy = proxy,
        location = nil,
        getInfo = nil,
        update = nil
    }

    local function update()
        if dataProxy.proxy then
            local info = dataProxy.proxy.getSensorInformation()
            local x, y, z = dataProxy.proxy.getCoordinates()
            dataProxy.location = {x = x, y = y, z = z}
        end
    end
    local function getInfo()
        local info = {
         [1] = dataProxy.name
        }
        return info
    end
    dataProxy.getInfo = getInfo
    dataProxy.update = update

    update()
    return dataProxy
end

return getProxy