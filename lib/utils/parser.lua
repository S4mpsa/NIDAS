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
    if math.abs(number) < 1000 then return tostring(math.floor(number)) end
    local suffixes = {"K", "M", "G", "T", "P", "E", "Z"}
    local power = 1
    while math.abs((number / 1000 ^ power)) > 1000 do power = power + 1 end
    return tostring(string.format("%.1f", (number / 1000 ^ power)))..suffixes[power]
end

function parser.getInteger(string)
    local numberString = string.gsub(string, "([^0-9]+)", "")
    if tonumber(numberString) then
        return math.floor(tonumber(numberString) + 0)
    end
    return nil
end

function parser.split(string, sep)
    if sep == nil then sep = "%s" end
    local words = {}
    for str in string.gmatch(string, "([^"..sep.."]+)") do
        table.insert(words, str)
    end
    return words
end

function parser.percentage(number) return
    (math.floor(number * 1000) / 10) .. "%" end

return parser
