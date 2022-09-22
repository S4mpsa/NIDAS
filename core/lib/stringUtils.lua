local stringUtils = {}

function stringUtils.split(string, separator)
    separator = separator or " "
    local result = {}
    local regex = ("([^%s]+)"):format(separator)
    for each in string:gmatch(regex) do
       table.insert(result, each)
    end
    return result
end

return stringUtils
