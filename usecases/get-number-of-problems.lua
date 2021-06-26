local function exec(multiblock)
    local problemsString = multiblock:getSensorInformation()[5]
    local problems = string.sub(problemsString, string.find(problemsString, "c%d"))
    return tonumber((string.gsub(problems, "c", "")))
end

return exec
