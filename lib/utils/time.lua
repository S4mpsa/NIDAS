local time = {}

local function split(string, separator)
    separator = separator or "%s"
    local t = {}
    for str in string.gmatch(string, "([^" .. separator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function time.offset(offset, timeJSON)
    offset = offset or 0
    local data = timeJSON
    if #data < 3 then return "-" end
    data = split(data, ",")[2]
    data = split(data, "-")[3]
    data = data:sub(data:find("T") + 1, data:find("Z") - 1)
    local hours = data:sub(1, 2)
    local minutes = data:sub(4, 5)
    if math.floor(minutes) <= 9 then
        minutes = "0" .. math.floor(minutes)
    else
        minutes = math.floor(minutes)
    end
    if offset ~= 0 then hours = (hours + offset) % 24 end
    return math.floor(hours) .. ":" .. minutes
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
