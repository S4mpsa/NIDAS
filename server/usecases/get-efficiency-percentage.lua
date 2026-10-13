local function exec(efficiencyString)
    local noParagraphMarkString = string.gsub(efficiencyString or "", "§r", "")
    local efficiency = "0.0"
    pcall(
        function()
            efficiency = string.sub(noParagraphMarkString, string.find(noParagraphMarkString, "%d+%.*%d*%s%%"))
        end
    )
    return tonumber((string.gsub(efficiency, "%s%%", "")))
end

return exec
