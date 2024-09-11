local stringUtils = {}

function stringUtils.split(string, sep)
    if sep == nil then sep = "%s" end
    local words = {}
    for str in string.gmatch(string, "([^"..sep.."]+)") do
        table.insert(words, str)
    end
    return words
end

function stringUtils.stripFormatting(str)
    return str:gsub("§.", '')
end

function stringUtils.contains(str, substring)
    if string.match(str, substring) then
        return true
    else
        return false
    end
end

function stringUtils.metricNumber(number, format)
    format = format or "%.1f"
    if math.abs(number) < 1000 then return tostring(math.floor(number)) end
    local suffixes = {"k", "M", "G", "T", "P", "E", "Z", "Y"}
    local power = 1
    while math.abs((number / 1000 ^ power)) > 1000 do power = power + 1 end
    return tostring(string.format(format, (number / 1000 ^ power)))..suffixes[power]
end

function stringUtils.splitNumber(number, delim)
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

function stringUtils.percentage(number)
    return (math.floor(number * 1000) / 10) .. "%"
end

---Returns the length of the longest string in a table of strings
---@param table string[]
---@return integer
function stringUtils.getLongestString(table, stripFormatting)
    local longest = -1
    for i, str in ipairs(table) do
        if stripFormatting then
            local strippedStr = stringUtils.stripFormatting(str)
            if #strippedStr > longest then
                longest = #strippedStr
            end
        else
            if #str > longest then
             longest = #str
            end
        end
    end
    return longest
end

return stringUtils