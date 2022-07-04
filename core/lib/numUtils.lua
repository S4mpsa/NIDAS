numUtils = {}


function numUtils.clamp(number, min, max)
    return math.min(max, math.max(min, number))
end

return numUtils