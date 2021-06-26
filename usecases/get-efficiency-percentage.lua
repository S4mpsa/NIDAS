local function exec(multiblock)
    local efficiencyString = multiblock:getSensorInformation()[5]
    local noParagraphMarkString = string.gsub(efficiencyString, "§r", "")
    local efficiency = string.sub(noParagraphMarkString, string.find(noParagraphMarkString, "%d+%.*%d*%s%%"))
    return tonumber((string.gsub(efficiency, "%s%%", "")))
end

return exec
