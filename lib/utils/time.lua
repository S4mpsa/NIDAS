local filesystem = require("filesystem")

local time = {}

local function split(string, separator)
    separator = separator or "%s"
    local t = {}
    for str in string.gmatch(string, "([^" .. separator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function time.realtime()
    local filename = "/home/NIDAS/settings/timefile"
    local file = filesystem.open("/home/NIDAS/settings/timefile", "a") -- touch file
    if file then
        file:close()
        local timestamp = filesystem.lastModified(filename) / 1000
        filesystem.remove(filename)
        return timestamp
    else
        return 0
    end
end

function time.offset(offset, UNIXTime)
    offset = offset or 0
    local offsetTime = UNIXTime + (3600 * offset)
    local timetable = os.date("*t", offsetTime)
    if timetable.min < 10 then
        timetable.min = "0"..timetable.min
    end
    return timetable.hour .. ":" .. timetable.min
end

-- Returns a given number in seconds formatted as Hours Minutes Seconds
function time.format(number)
    if number == 0 then
        return 0
    else
        local hours = math.floor(number / 3600)
        local minutes = math.floor((number - math.floor(number / 3600) * 3600) /
                                       60)
        local seconds = (number % 60)
        if hours > 17000 then
            local years = math.floor(hours / (24 * 365))
            local days = math.floor((hours - (years * 24 * 365)) / 24)
            return (years .. " Years " .. days .. " Days")
        elseif hours > 48 then
            local days = math.floor(hours / 24)
            hours = math.floor(hours - days * 24)
            return (days .. "d " .. hours .. "h " .. minutes .. "m")
        else
            return (hours .. "h " .. minutes .. "m " .. seconds .. "s")
        end
    end
end

return time
