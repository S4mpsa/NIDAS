local function exec(multiblock)
    local efficiencyString = multiblock:getSensorInformation()[5]
    local noParagraphMarkString = string.gsub(efficiencyString, "§r", "")
    local efficiency = "0.0"
    pcall(
        function()
            efficiency = string.sub(noParagraphMarkString, string.find(noParagraphMarkString, "%d+%.*%d*%s%%"))
        end
    )
    return tonumber((string.gsub(efficiency, "%s%%", "")))
end

return exec
