numUtils = {}


function numUtils.clamp(number, min, max)
    return math.min(max, math.max(min, number))
end

function numUtils.numberToColourHex(number)
    local hex = string.format("%x", tostring(number))
    while #hex < 6 do
        hex = "0" .. hex
    end
    hex = "0x" .. string.upper(hex)
    return hex

end

return numUtils