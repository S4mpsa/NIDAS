local numUtils = {}


function numUtils.clamp(number, min, max)
    return math.min(max, math.max(min, number))
end

function numUtils.toRGB(hex)
    local r = ((hex >> 16) & 0xFF) / 255.0
    local g = ((hex >> 8) & 0xFF) / 255.0
    local b = ((hex) & 0xFF) / 255.0
    return r, g, b
end

function numUtils.numberToColourHex(number)
    local hex = string.format("%x", tostring(number))
    while #hex < 6 do
        hex = "0" .. hex
    end
    hex = "0x" .. string.upper(hex)
    return hex

end

function numUtils.getInteger(string)
    if type(string) == "string" then
        local numberString = string.gsub(string, "([^0-9]+)", "")
        if tonumber(numberString) then
            return math.floor(tonumber(numberString) + 0)
        end
        return 0
    else
        return 0
    end
end

return numUtils