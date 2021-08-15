local parser = {}

-- Returns given number formatted as XXX,XXX,XXX
function parser.splitNumber(number, delim)
    delim = delim or ","
    if delim == "" then return tostring(number) end
    local formattedNumber = {}
    local string = tostring(math.abs(number))
    local sign = number / math.abs(number)
    for i = 1, #string do
        local n = string:sub(i, i)
        formattedNumber[i] = n
        if ((#string - i) % 3 == 0) and (#string - i > 0) then
            formattedNumber[i] = formattedNumber[i] .. delim
        end
    end
    if (sign < 0) then table.insert(formattedNumber, 1, "-") end
    return table.concat(formattedNumber, "")
end

function parser.metricNumber(number)
    local suffixes = {"K", "M", "G", "T", "P", "E", "Z"}
    local power = 1
    while math.abs((number / 1000 ^ power)) > 1000 do power = power + 1 end
    return tostring(string.format("%.1f", (number / 1000 ^ power)))..suffixes[power]
end

function parser.getInteger(string)
    return math.floor(string.gsub(string, "([^0-9]+)", "") + 0)
end

function parser.percentage(number) return
    (math.floor(number * 1000) / 10) .. "%" end

return parser
