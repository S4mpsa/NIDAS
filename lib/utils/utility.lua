local component = require("component")
local internet = require("internet")
local utility = {}

function utility.machine(address)
    local proxy = component.get(address)
    if(proxy ~= nil) then
        return component.proxy(proxy)
    else
        return nil
    end
end
function utility.RGB(hex)
    local r = ((hex >> 16) & 0xFF) / 255.0
    local g = ((hex >> 8) & 0xFF) / 255.0
    local b = ((hex) & 0xFF) / 255.0
    return r, g, b
end
--Small = 1, Normal = 2, Large = 3, Auto = 4x to 10x (Even)
function utility.screensize(resolution, scale)
    scale = scale or 3
    return {resolution[1]/scale, resolution[2]/scale}
end
--Returns given number formatted as XXX,XXX,XXX
function utility.splitNumber(number)
    local formattedNumber = {}
    local string = tostring(math.abs(number))
    local sign = number/math.abs(number)
    for i = 1, #string do
      n = string:sub(i, i)
      formattedNumber[i] = n
      if ((#string-i) % 3 == 0) and (#string-i > 0) then
        formattedNumber[i] = formattedNumber[i] .. ","
      end
    end
    if(sign < 0) then table.insert(formattedNumber, 1, "-") end
    return table.concat(formattedNumber, "")
end
--Returns a given number in seconds formatted as Hours Minutes Seconds
function utility.time(number)
    if number == 0 then return 0 else
        local hours =  math.floor(number/3600)
        local minutes = math.floor((number - math.floor(number/3600)*3600)/60)
        local seconds = (number%60)
        if hours > 17000 then
            local years = math.floor(hours/(24*365))
            local days = math.floor((hours - (years * 24 * 365)) / 24)
            return (years.." Years "..days.." Days")
        elseif hours > 48 then
            local days = math.floor(hours/24)
            hours = math.floor(hours-days*24)
            return (days.."d "..hours.."h "..minutes.."m")
        else
            return (hours.."h "..minutes.."m "..seconds.."s")
        end
    end
end

function utility.split (string, separator)
    separator = separator or "%s"
    local t={}
    for str in string.gmatch(string, "([^"..separator.."]+)") do table.insert(t, str) end
    return t
end
function utility.offsetTime(offset, timeJSON)
    offset = offset or 0
    local data = timeJSON
    if #data < 3 then return nil end
    data = utility.split(data, ",")[2]
    data = utility.split(data, "-")[3]
    data = data:sub(data:find("T")+1, data:find("Z")-1)
    local hours = data:sub(1, 2)
    local minutes = data:sub(4, 5)
    if math.floor(minutes) <= 9 then minutes = "0"..math.floor(minutes) else minutes = math.floor(minutes) end
    if offset ~= 0 then
        hours = (hours + offset) % 24
    end
    return math.floor(hours)..":"..minutes
end

function utility.getInteger(string)
    return math.floor(string.gsub(string, "([^0-9]+)", "") + 0)
end

function utility.percentage(number)
    return (math.floor(number*1000)/10).."%"
end

return utility