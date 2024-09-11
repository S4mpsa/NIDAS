local numUtils = require("core.lib.numUtils")
local stringUtils = require("core.lib.stringUtils")
local getMaintenanceStatus = require("core.network.data.utils.getMaintenanceStatus")

local function getProxy(proxy)

    local dataProxy = {
        name = "Lapotronic Supercapacitor",
        short = "LSC",
        proxy = proxy,
        location = nil,
        currentCapacity = nil,
        maxCapacity = nil,
        input = nil,
        output = nil,
        wirelessMode = nil,
        wirelessEU = nil,
        maintenance = nil,
        running = nil,
        getInfo = nil,
        update = nil
    }

    local function update()
        if dataProxy.proxy then --Only update if the machine is local
            local info = dataProxy.proxy.getSensorInformation()
            local x, y, z = dataProxy.proxy.getCoordinates()
            dataProxy.name = machineNames[dataProxy.proxy.address] or dataProxy.name
            dataProxy.location = {x = x, y = y, z = z}
            dataProxy.currentCapacity = numUtils.getInteger(info[2])
            dataProxy.maxCapacity = numUtils.getInteger(info[3])
            dataProxy.input = numUtils.getInteger(info[5])
            dataProxy.output = numUtils.getInteger(info[6])
            dataProxy.wirelessMode = stringUtils.contains(info[10], "enabled")
            dataProxy.maintenance = getMaintenanceStatus(info[9])
            dataProxy.wirelessEU = numUtils.getInteger(info[13])
            dataProxy.running = dataProxy.proxy.isMachineActive()
        end
    end
    local function getInfo()
        local percentageString = ""
        local wirelessString = ""
        local statusString = ""
        local percentage = dataProxy.currentCapacity / dataProxy.maxCapacity
        if percentage < 0.0005 then
            percentageString = string.format("%.5f", math.floor(percentage*10000000)/100000).."%"
        else
            percentageString = string.format("%.2f", math.floor(percentage*10000000)/100000).."%"
        end
        if dataProxy.wirelessMode then
            wirelessString = "Wireless: §2Enabled§r - " .. stringUtils.metricNumber(dataProxy.wirelessEU, "%.3f") .. " §rEU"
        else
            wirelessString = "Wireless: §4DInactive§r"
        end
        if dataProxy.running then
            if dataProxy.maintenance then
                statusString = "§5Requires Maintenance§r"
            else
                statusString = "§aRunning§r"
            end
        else
            statusString = "§cDisabled§r"
        end
        local info = {
            [1] = "§6" .. dataProxy.name .. "§r",
            [2] = "Current Capacity: §a" .. stringUtils.metricNumber(dataProxy.currentCapacity, "%.3f") .. "§rEU",
            [3] = "Maximum Capacity: §b" .. stringUtils.metricNumber(dataProxy.maxCapacity, "%.3f") .. "§rEU",
            [4] = "Fill level: §d" .. percentageString,
            [5] = wirelessString,
            [6] = "Status: " ..statusString
        }
        return info
    end
    
    dataProxy.getInfo = getInfo
    dataProxy.update = update

    update()
    return dataProxy
end

return getProxy